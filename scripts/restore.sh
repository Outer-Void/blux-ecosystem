#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# BLUX Restore Script
# Restores a previously created backup

BACKUP_SRC=""
DRY_RUN=false
VERIFY_ONLY=false

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS] <backup_directory>

BLUX Development Restore Script
Restores a previously created backup

Options:
    --dry-run           Show what would be restored without doing it
    --verify-only       Verify the backup without restoring
    --help              Show this help message

Arguments:
    <backup_directory>  Path to the backup directory to restore from

Examples:
    $0 backups/pre-feature-x
    $0 --dry-run backups/pre-feature-x
    $0 --verify-only backups/pre-feature-x

Available backups:
    $(ls backups/ 2>/dev/null | head -10 | tr '\n' ' ' || echo "None")
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --verify-only)
            VERIFY_ONLY=true
            shift
            ;;
        --help)
            show_usage
            exit 0
            ;;
        -*)
            log_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
        *)
            BACKUP_SRC="$1"
            shift
            ;;
    esac
done

# Validate backup source
validate_backup() {
    if [ -z "$BACKUP_SRC" ]; then
        log_error "No backup directory specified"
        show_usage
        exit 1
    fi
    
    if [ ! -d "$BACKUP_SRC" ]; then
        log_error "Backup directory not found: $BACKUP_SRC"
        echo "Available backups:"
        ls -la backups/ 2>/dev/null || echo "  No backups found"
        exit 1
    fi
    
    local metadata_file="$BACKUP_SRC/backup.metadata"
    local files_list="$BACKUP_SRC/files.txt"
    
    if [ ! -f "$metadata_file" ]; then
        log_warning "Backup metadata not found - may not be a valid BLUX backup"
    fi
    
    if [ ! -f "$files_list" ]; then
        log_error "Backup file list not found - invalid backup format"
        exit 1
    fi
    
    log_info "Valid backup found: $BACKUP_SRC"
}

# Show backup information
show_backup_info() {
    local metadata_file="$BACKUP_SRC/backup.metadata"
    
    if [ -f "$metadata_file" ]; then
        echo
        echo "Backup Information:"
        echo "------------------"
        cat "$metadata_file"
    fi
    
    local file_count
    file_count=$(wc -l < "$BACKUP_SRC/files.txt" 2>/dev/null || echo "0")
    echo "Files to restore: $file_count"
}

# Verify backup contents
verify_backup() {
    log_info "Verifying backup contents..."
    
    local files_list="$BACKUP_SRC/files.txt"
    local missing_files=0
    local total_files=0
    
    while IFS= read -r file; do
        local backup_file="$BACKUP_SRC/$file"
        if [ ! -f "$backup_file" ]; then
            log_warning "Missing in backup: $file"
            ((missing_files++))
        fi
        ((total_files++))
    done < "$files_list"
    
    if [ $missing_files -eq 0 ]; then
        log_success "Backup verification passed - all $total_files files present"
    else
        log_warning "Backup verification: $missing_files files missing out of $total_files"
    fi
}

# Dry run - show what would be restored
dry_run_restore() {
    log_info "Dry run - showing what would be restored"
    
    local files_list="$BACKUP_SRC/files.txt"
    local changes=0
    local additions=0
    
    echo
    echo "Files to be restored:"
    echo "--------------------"
    
    while IFS= read -r file; do
        local backup_file="$BACKUP_SRC/$file"
        local current_file="$file"
        
        if [ -f "$current_file" ]; then
            if cmp -s "$backup_file" "$current_file"; then
                echo "  UNCHANGED: $file"
            else
                echo "  UPDATE:    $file"
                ((changes++))
            fi
        else
            echo "  ADD:       $file"
            ((additions++))
        fi
    done < "$files_list"
    
    echo
    echo "Summary:"
    echo "  Files to update: $changes"
    echo "  Files to add:    $additions"
}

# Perform the restore
perform_restore() {
    log_info "Restoring from backup: $BACKUP_SRC"
    
    local files_list="$BACKUP_SRC/files.txt"
    local restored=0
    local errors=0
    
    # Create a restore log
    local restore_log="restore-$(date +%Y%m%d-%H%M%S).log"
    
    {
        echo "Restore started: $(date -Iseconds)"
        echo "Backup source: $BACKUP_SRC"
        echo "---"
        
        while IFS= read -r file; do
            local backup_file="$BACKUP_SRC/$file"
            local current_file="$file"
            
            if [ -f "$backup_file" ]; then
                # Create directory if needed
                local file_dir
                file_dir=$(dirname "$current_file")
                mkdir -p "$file_dir"
                
                # Copy the file
                if cp "$backup_file" "$current_file"; then
                    echo "RESTORED: $file"
                    ((restored++))
                else
                    echo "ERROR:    $file"
                    ((errors++))
                fi
            else
                echo "MISSING:  $file (in backup)"
                ((errors++))
            fi
        done < "$files_list"
        
        echo "---"
        echo "Restore completed: $(date -Iseconds)"
        echo "Files restored: $restored"
        echo "Errors: $errors"
        
    } > "$restore_log"
    
    if [ $errors -eq 0 ]; then
        log_success "Restore completed: $restored files restored"
        log_info "Restore log: $restore_log"
    else
        log_warning "Restore completed with $errors errors"
        log_info "Check restore log: $restore_log"
    fi
}

# Post-restore verification
post_restore_verify() {
    log_info "Performing post-restore verification..."
    
    if command -v git &> /dev/null && git rev-parse --is-inside-work-tree &> /dev/null; then
        log_info "Git status after restore:"
        git status --short || true
    fi
    
    # Run health check if available
    if [ -f "scripts/health-check.sh" ]; then
        log_info "Running health check..."
        ./scripts/health-check.sh --quick || true
    fi
}

main() {
    echo "🔄 BLUX Development Restore"
    echo "=========================="
    
    validate_backup
    show_backup_info
    
    if [ "$VERIFY_ONLY" = true ]; then
        verify_backup
        exit 0
    fi
    
    if [ "$DRY_RUN" = true ]; then
        dry_run_restore
    else
        # Confirm restore
        echo
        log_warning "This will overwrite current files with backup contents!"
        read -p "Continue with restore? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Restore cancelled"
            exit 0
        fi
        
        verify_backup
        perform_restore
        post_restore_verify
        
        log_success "Restore process completed"
        log_info "Remember to run tests and verify system functionality"
    fi
}

main "$@"
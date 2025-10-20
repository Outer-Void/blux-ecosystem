#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# BLUX Backup Script
# Creates backups of the current state for safe development

TAG=""
DRY_RUN=false
INCLUDE_AUDIT=false
BACKUP_DIR="backups"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

BLUX Development Backup Script
Creates backups of current state for safe development and experimentation

Options:
    --tag NAME           Tag for the backup (default: backup-YYYY-MM-DD-HHMMSS)
    --dry-run           Show what would be backed up without doing it
    --include-audit     Include audit logs in backup (caution: may be large)
    --help              Show this help message

Examples:
    $0 --tag pre-feature-x
    $0 --dry-run
    $0 --include-audit --tag pre-security-update

Backups are stored in: $BACKUP_DIR/
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --tag)
            TAG="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --include-audit)
            INCLUDE_AUDIT=true
            shift
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            log_warning "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Generate backup tag
generate_tag() {
    if [ -z "$TAG" ]; then
        TAG="backup-$(date +%Y-%m-%d-%H%M%S)"
    fi
}

# Validate backup directory
setup_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        log_info "Created backup directory: $BACKUP_DIR"
    fi
}

# Check if backup already exists
check_existing_backup() {
    local backup_path="$BACKUP_DIR/$TAG"
    if [ -d "$backup_path" ]; then
        log_warning "Backup with tag '$TAG' already exists"
        read -p "Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Backup cancelled"
            exit 0
        fi
        log_info "Overwriting existing backup"
    fi
}

# Get list of files to backup
get_files_to_backup() {
    local files=()
    
    # Use git to get tracked files
    if command -v git &> /dev/null && git rev-parse --is-inside-work-tree &> /dev/null; then
        # Get all tracked files
        while IFS= read -r file; do
            if [ -f "$file" ]; then
                files+=("$file")
            fi
        done < <(git ls-files)
        
        # Add specific important files that might be gitignored
        local important_files=(
            ".env"
            "config/local.yaml"
            "manifests/local.manifest.json"
        )
        
        for file in "${important_files[@]}"; do
            if [ -f "$file" ]; then
                files+=("$file")
            fi
        done
    else
        # Fallback: find all files except backup directory and common large dirs
        while IFS= read -r file; do
            files+=("$file")
        done < <(find . -type f -not -path "./$BACKUP_DIR/*" \
                                 -not -path "./node_modules/*" \
                                 -not -path "./.git/*" \
                                 -not -path "./dist/*" \
                                 -not -path "./build/*" \
                                 -not -path "./.venv/*" \
                                 -not -name "*.pyc" \
                                 -not -name "*.log" \
                                 2>/dev/null || true)
    fi
    
    # Add audit logs if requested
    if [ "$INCLUDE_AUDIT" = true ]; then
        local audit_path="${BLUX_AUDIT_PATH:-~/.config/blux/audit/}"
        audit_path="${audit_path/#\~/$HOME}"
        if [ -d "$audit_path" ]; then
            while IFS= read -r audit_file; do
                files+=("$audit_file")
            done < <(find "$audit_path" -name "*.jsonl" -type f 2>/dev/null || true)
        else
            log_warning "Audit path not found: $audit_path"
        fi
    fi
    
    printf "%s\n" "${files[@]}"
}

# Create the backup
create_backup() {
    local backup_path="$BACKUP_DIR/$TAG"
    local files_list="$backup_path/files.txt"
    
    log_info "Creating backup: $TAG"
    mkdir -p "$backup_path"
    
    # Get files and save list
    local files=($(get_files_to_backup))
    printf "%s\n" "${files[@]}" > "$files_list"
    
    log_info "Backing up ${#files[@]} files..."
    
    # Copy files
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            local dest_dir="$backup_path/$(dirname "$file")"
            mkdir -p "$dest_dir"
            cp "$file" "$dest_dir/"
        fi
    done
    
    # Save metadata
    cat > "$backup_path/backup.metadata" << EOF
Backup created: $(date -Iseconds)
Tag: $TAG
Total files: ${#files[@]}
Include audit: $INCLUDE_AUDIT
Git commit: $(git rev-parse HEAD 2>/dev/null || echo "unknown")
User: $(whoami)
Host: $(hostname)
EOF

    # Save current state summary
    if command -v git &> /dev/null && git rev-parse --is-inside-work-tree &> /dev/null; then
        git status > "$backup_path/git-status.txt"
        git diff > "$backup_path/git-diff.txt" 2>/dev/null || true
        git log --oneline -10 > "$backup_path/git-log.txt"
    fi
}

# Dry run - show what would be backed up
dry_run() {
    log_info "Dry run - showing what would be backed up"
    
    local files=($(get_files_to_backup))
    local total_size=0
    
    echo
    echo "Files to be backed up (${#files[@]} total):"
    echo "------------------------------------------"
    
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            local size
            size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
            total_size=$((total_size + size))
            echo "  $file ($((size / 1024)) KB)"
        fi
    done
    
    echo
    echo "Total size: $((total_size / 1024 / 1024)) MB"
    echo "Backup location: $BACKUP_DIR/$TAG"
    echo "Include audit: $INCLUDE_AUDIT"
}

# Show backup information
show_backup_info() {
    local backup_path="$BACKUP_DIR/$TAG"
    
    if [ "$DRY_RUN" = false ]; then
        log_success "Backup completed: $backup_path"
        
        echo
        echo "Backup contents:"
        echo "---------------"
        echo "Files: $(find "$backup_path" -type f | wc -l)"
        echo "Size: $(du -sh "$backup_path" | cut -f1)"
        echo
        echo "To restore: ./scripts/restore.sh $backup_path"
        echo "To list:    ls -la $backup_path/"
        
        # Show recent backups
        echo
        echo "Recent backups:"
        ls -lt "$BACKUP_DIR" | head -10
    fi
}

main() {
    echo "💾 BLUX Development Backup"
    echo "========================="
    
    generate_tag
    setup_backup_dir
    
    if [ "$DRY_RUN" = true ]; then
        dry_run
    else
        check_existing_backup
        create_backup
        show_backup_info
    fi
}

main "$@"
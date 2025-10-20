#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# BLUX Patch Application Script
# Safely applies patches with validation

PATCH_FILE="${1:-}"
DRY_RUN=false
BACKUP=true

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

show_usage() {
    echo "Usage: $0 [OPTIONS] <patch-file>"
    echo ""
    echo "Apply patches safely with validation"
    echo ""
    echo "Options:"
    echo "  --dry-run    Show what would be applied without making changes"
    echo "  --no-backup  Skip creating backup before applying"
    echo "  --help       Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 patches/2025-10-20-feature.patch"
    echo "  $0 --dry-run patches/2025-10-20-feature.patch"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --no-backup)
            BACKUP=false
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
            PATCH_FILE="$1"
            shift
            ;;
    esac
done

# Validate patch file
validate_patch_file() {
    if [ -z "$PATCH_FILE" ]; then
        log_error "No patch file specified"
        show_usage
        exit 1
    fi
    
    if [ ! -f "$PATCH_FILE" ]; then
        log_error "Patch file not found: $PATCH_FILE"
        exit 1
    fi
    
    if [ ! -s "$PATCH_FILE" ]; then
        log_error "Patch file is empty: $PATCH_FILE"
        exit 1
    fi
    
    log_info "Using patch file: $PATCH_FILE"
}

# Create backup
create_backup() {
    if [ "$BACKUP" = true ]; then
        local backup_tag="pre-patch-$(date +%Y%m%d-%H%M%S)"
        log_info "Creating backup: $backup_tag"
        
        if [ -f "scripts/backup.sh" ]; then
            ./scripts/backup.sh --tag "$backup_tag"
        else
            log_warning "Backup script not found, skipping backup"
        fi
    fi
}

# Validate patch content
validate_patch() {
    log_info "Validating patch content..."
    
    # Check if patch can be applied
    if git apply --check "$PATCH_FILE" 2>/dev/null; then
        log_info "Patch validation passed"
        return 0
    else
        log_error "Patch validation failed - cannot apply cleanly"
        log_info "Try: git apply --reject '$PATCH_FILE' to see conflicts"
        return 1
    fi
}

# Show patch statistics
show_patch_stats() {
    log_info "Patch statistics:"
    
    local file_count
    file_count=$(grep -c "^---" "$PATCH_FILE" || true)
    echo "  Files modified: $file_count"
    
    local addition_count
    addition_count=$(grep -c "^+" "$PATCH_FILE" || true)
    echo "  Lines added: $addition_count"
    
    local deletion_count
    deletion_count=$(grep -c "^-" "$PATCH_FILE" || true)
    echo "  Lines deleted: $deletion_count"
}

# Apply the patch
apply_patch() {
    if [ "$DRY_RUN" = true ]; then
        log_info "Dry run - showing what would be applied:"
        git apply --stat "$PATCH_FILE"
        return 0
    fi
    
    log_info "Applying patch..."
    
    if git apply "$PATCH_FILE"; then
        log_info "Patch applied successfully"
        return 0
    else
        log_error "Failed to apply patch"
        return 1
    fi
}

# Verify application
verify_patch() {
    if [ "$DRY_RUN" = false ]; then
        log_info "Verifying patch application..."
        
        # Check if any files are modified
        if git diff --quiet; then
            log_warning "No changes detected after patch application"
        else
            log_info "Changes confirmed in working directory"
        fi
    fi
}

main() {
    echo "🔧 BLUX Patch Application"
    echo "========================"
    
    validate_patch_file
    show_patch_stats
    
    if validate_patch; then
        create_backup
        
        if apply_patch; then
            verify_patch
            log_info "Patch application complete"
        else
            log_error "Patch application failed"
            exit 1
        fi
    else
        exit 1
    fi
}

main "$@"
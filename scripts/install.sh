#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# BLUX Ecosystem Install Script
# Installs helper scripts and development tools

echo "🔧 BLUX Ecosystem Installation"
echo "=============================="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

# Make scripts executable
make_scripts_executable() {
    log_info "Making scripts executable..."
    
    if [ -d "scripts" ]; then
        for script in scripts/*.sh; do
            if [ -f "$script" ]; then
                chmod +x "$script"
                log_info "Made executable: $script"
            fi
        done
    else
        log_info "No scripts directory found"
    fi
}

# Install git hooks if pre-commit is available
install_git_hooks() {
    if command -v pre-commit &> /dev/null; then
        log_info "Installing Git hooks..."
        pre-commit install
        pre-commit install --hook-type commit-msg
        log_success "Git hooks installed"
    else
        log_info "pre-commit not available, skipping Git hooks"
        log_info "Install with: pip install pre-commit"
    fi
}

# Create necessary directories
create_directories() {
    log_info "Creating necessary directories..."
    
    local dirs=(
        "backups"
        "patches"
        "logs"
        "tmp"
    )
    
    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            log_info "Created directory: $dir"
        fi
    done
}

# Display completion message
show_completion() {
    echo
    log_success "Installation complete!"
    echo
    echo "Available commands:"
    echo "  ./scripts/bootstrap.sh     - Setup development environment"
    echo "  ./scripts/health-check.sh  - Verify system health"
    echo "  ./scripts/backup.sh        - Create backups before changes"
    echo "  ./scripts/anchor-list.sh   - List development anchors"
    echo
    echo "Next: Run './scripts/bootstrap.sh' to setup your environment"
}

# Main installation
main() {
    make_scripts_executable
    install_git_hooks
    create_directories
    show_completion
}

main "$@"
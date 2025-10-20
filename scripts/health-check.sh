#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# BLUX Ecosystem Health Check Script
# Verifies system health and readiness

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
QUICK_MODE=false
VERBOSE=false
CHECK_SERVICES=true
CHECK_CONFIG=true
CHECK_SECURITY=true

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_debug() { if [ "$VERBOSE" = true ]; then echo -e "${BLUE}[DEBUG]${NC} $1"; fi; }

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --quick)
            QUICK_MODE=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --no-services)
            CHECK_SERVICES=false
            shift
            ;;
        --no-config)
            CHECK_CONFIG=false
            shift
            ;;
        --no-security)
            CHECK_SECURITY=false
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo "Health check for BLUX Ecosystem"
            echo ""
            echo "Options:"
            echo "  --quick        Quick check only"
            echo "  --verbose      Verbose output"
            echo "  --no-services  Skip service checks"
            echo "  --no-config    Skip configuration checks"
            echo "  --no-security  Skip security checks"
            echo "  --help         Show this help"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Counters
total_checks=0
passed_checks=0
failed_checks=0
warnings=0

# Check functions
increment_passed() { ((total_checks++)); ((passed_checks++)); }
increment_failed() { ((total_checks++)); ((failed_checks++)); }
increment_warning() { ((total_checks++)); ((warnings++)); }

check_directory_structure() {
    log_info "Checking directory structure..."
    
    local required_dirs=(
        "scripts"
        "docs"
        "manifests"
        "config"
    )
    
    for dir in "${required_dirs[@]}"; do
        if [ -d "$dir" ]; then
            log_debug "Directory exists: $dir"
            increment_passed
        else
            log_error "Missing directory: $dir"
            increment_failed
        fi
    done
}

check_script_executables() {
    log_info "Checking script executables..."
    
    local scripts=(
        "scripts/bootstrap.sh"
        "scripts/health-check.sh"
        "scripts/backup.sh"
        "scripts/restore.sh"
        "scripts/anchor-list.sh"
        "scripts/patch-apply.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [ -f "$script" ] && [ -x "$script" ]; then
            log_debug "Script executable: $script"
            increment_passed
        else
            if [ -f "$script" ]; then
                log_warning "Script not executable: $script"
                increment_warning
            else
                log_error "Missing script: $script"
                increment_failed
            fi
        fi
    done
}

check_configuration_files() {
    if [ "$CHECK_CONFIG" = false ]; then
        return 0
    fi
    
    log_info "Checking configuration files..."
    
    local config_files=(
        "config/development.yaml"
        ".env.example"
        "manifests/hub.manifest.json"
        "manifests/policy.doctrine.json"
    )
    
    for config_file in "${config_files[@]}"; do
        if [ -f "$config_file" ]; then
            # Basic syntax check for JSON files
            if [[ "$config_file" == *.json ]]; then
                if python3 -m json.tool "$config_file" > /dev/null 2>&1; then
                    log_debug "Valid JSON: $config_file"
                    increment_passed
                else
                    log_error "Invalid JSON: $config_file"
                    increment_failed
                fi
            else
                log_debug "Config file exists: $config_file"
                increment_passed
            fi
        else
            log_warning "Missing config file: $config_file"
            increment_warning
        fi
    done
}

check_documentation() {
    log_info "Checking documentation..."
    
    local docs=(
        "README.md"
        "ARCHITECTURE.md"
        "SECURITY_OVERVIEW.md"
        "DEVELOPER_GUIDE.md"
        "INTEGRATION_GUIDE.md"
        "CHANGELOG.md"
    )
    
    for doc in "${docs[@]}"; do
        if [ -f "$doc" ]; then
            # Check if file has content
            if [ -s "$doc" ]; then
                log_debug "Documentation exists: $doc"
                increment_passed
            else
                log_warning "Empty documentation: $doc"
                increment_warning
            fi
        else
            log_error "Missing documentation: $doc"
            increment_failed
        fi
    done
}

check_security() {
    if [ "$CHECK_SECURITY" = false ]; then
        return 0
    fi
    
    log_info "Checking security basics..."
    
    # Check for presence of security documentation
    if [ -f "SECURITY.md" ]; then
        log_debug "Security policy exists"
        increment_passed
    else
        log_warning "Missing SECURITY.md"
        increment_warning
    fi
    
    # Check for secrets in files (basic check)
    if command -v git &> /dev/null; then
        if git grep -l "password\|secret\|key" -- "*.md" "*.yaml" "*.json" | grep -v -E "(SECURITY|CHANGELOG|README)" > /dev/null; then
            log_warning "Potential secrets found in files"
            increment_warning
        else
            log_debug "No obvious secrets in documentation"
            increment_passed
        fi
    fi
    
    # Check .gitignore for sensitive files
    if [ -f ".gitignore" ]; then
        if grep -q -E "(.key|.pem|.cert|password|secret)" ".gitignore"; then
            log_debug ".gitignore covers sensitive files"
            increment_passed
        else
            log_warning ".gitignore may not cover all sensitive files"
            increment_warning
        fi
    fi
}

check_dependencies() {
    log_info "Checking dependencies..."
    
    local dependencies=(
        "git"
        "python3"
        "docker"
    )
    
    for dep in "${dependencies[@]}"; do
        if command -v "$dep" &> /dev/null; then
            log_debug "Dependency available: $dep"
            increment_passed
        else
            log_warning "Missing dependency: $dep"
            increment_warning
        fi
    done
}

check_anchors() {
    if [ "$QUICK_MODE" = true ]; then
        return 0
    fi
    
    log_info "Checking anchor consistency..."
    
    if [ -f "scripts/anchor-list.sh" ]; then
        local anchor_count
        anchor_count=$(./scripts/anchor-list.sh | grep -c "ANCHOR:" || true)
        
        if [ "$anchor_count" -gt 0 ]; then
            log_debug "Found $anchor_count anchors"
            increment_passed
        else
            log_warning "No anchors found - development workflow affected"
            increment_warning
        fi
    else
        log_error "Anchor listing script missing"
        increment_failed
    fi
}

# Quick health check (minimal)
quick_health_check() {
    log_info "Running quick health check..."
    
    check_directory_structure
    check_script_executables
    check_dependencies
}

# Full health check
full_health_check() {
    log_info "Running full health check..."
    
    check_directory_structure
    check_script_executables
    check_configuration_files
    check_documentation
    check_security
    check_dependencies
    check_anchors
}

# Summary function
show_summary() {
    echo
    echo "Health Check Summary"
    echo "==================="
    echo "Total checks:  $total_checks"
    echo -e "Passed:        ${GREEN}$passed_checks${NC}"
    echo -e "Warnings:      ${YELLOW}$warnings${NC}"
    echo -e "Failed:        ${RED}$failed_checks${NC}"
    echo
    
    if [ "$failed_checks" -eq 0 ]; then
        if [ "$warnings" -eq 0 ]; then
            log_success "All checks passed! BLUX Ecosystem is healthy."
        else
            log_warning "Health check completed with warnings."
            log_info "Review warnings above for potential improvements."
        fi
    else
        log_error "Health check failed with $failed_checks errors."
        log_info "Please address the errors above before proceeding."
        exit 1
    fi
    
    # Additional recommendations
    if [ "$warnings" -gt 0 ] || [ "$failed_checks" -gt 0 ]; then
        echo
        log_info "Recommendations:"
        [ "$CHECK_CONFIG" = true ] && echo "  Review configuration files"
        [ "$CHECK_SECURITY" = true ] && echo "  Review security settings"
        echo "  Run './scripts/bootstrap.sh' to fix common issues"
    fi
}

# Main execution
main() {
    echo "BLUX Ecosystem Health Check"
    echo "==========================="
    
    if [ "$QUICK_MODE" = true ]; then
        log_info "Quick mode enabled"
        quick_health_check
    else
        full_health_check
    fi
    
    show_summary
}

# Run main function
main "$@"
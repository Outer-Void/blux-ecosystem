#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# BLUX Dependency Security Check
# Checks for vulnerable dependencies and security issues

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check for required tools
check_tools() {
    local missing=()
    
    for tool in "$@"; do
        if ! command -v "$tool" &> /dev/null; then
            missing+=("$tool")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        log_warning "Missing tools: ${missing[*]}"
        return 1
    fi
    return 0
}

# Check Python dependencies
check_python_deps() {
    log_info "Checking Python dependencies..."
    
    if [ -f "requirements.txt" ]; then
        if check_tools "safety"; then
            safety check --file=requirements.txt
        else
            log_warning "safety not installed, skipping Python vulnerability check"
            log_info "Install with: pip install safety"
        fi
    else
        log_info "No requirements.txt found, skipping Python check"
    fi
}

# Check Node.js dependencies
check_node_deps() {
    log_info "Checking Node.js dependencies..."
    
    if [ -f "package.json" ]; then
        if check_tools "npm"; then
            if [ -d "node_modules" ]; then
                npm audit
            else
                log_warning "node_modules not found, run 'npm install' first"
            fi
        else
            log_warning "npm not available, skipping Node.js check"
        fi
    else
        log_info "No package.json found, skipping Node.js check"
    fi
}

# Check system dependencies
check_system_deps() {
    log_info "Checking system dependencies..."
    
    local critical_deps=("git" "python3")
    local optional_deps=("docker" "node" "jq" "yq")
    
    for dep in "${critical_deps[@]}"; do
        if command -v "$dep" &> /dev/null; then
            log_success "Critical dependency available: $dep"
        else
            log_error "Missing critical dependency: $dep"
        fi
    done
    
    for dep in "${optional_deps[@]}"; do
        if command -v "$dep" &> /dev/null; then
            log_success "Optional dependency available: $dep"
        else
            log_warning "Missing optional dependency: $dep"
        fi
    done
}

# Check for known vulnerable patterns
check_security_patterns() {
    log_info "Checking for security patterns..."
    
    local issues=0
    
    # Check for hardcoded secrets
    if command -v git &> /dev/null; then
        if git grep -l "password.*=" -- "*.py" "*.js" "*.ts" "*.go" "*.java" | grep -v "test" > /dev/null; then
            log_warning "Potential hardcoded passwords found"
            ((issues++))
        fi
    fi
    
    # Check file permissions
    local scripts_without_exec=0
    for script in scripts/*.sh; do
        if [ -f "$script" ] && [ ! -x "$script" ]; then
            ((scripts_without_exec++))
        fi
    done
    
    if [ $scripts_without_exec -gt 0 ]; then
        log_warning "$scripts_without_exec scripts are not executable"
        ((issues++))
    fi
    
    # Check for world-writable files
    local world_writable
    world_writable=$(find . -type f -perm -002 ! -path "./.git/*" ! -path "./node_modules/*" 2>/dev/null | wc -l)
    if [ "$world_writable" -gt 0 ]; then
        log_warning "$world_writable world-writable files found"
        ((issues++))
    fi
    
    if [ $issues -eq 0 ]; then
        log_success "No obvious security patterns detected"
    fi
}

# Check configuration security
check_config_security() {
    log_info "Checking configuration security..."
    
    # Check for default passwords in configs
    local default_password_files=()
    
    for config_file in config/*.yaml config/*.yml manifests/*.json; do
        if [ -f "$config_file" ]; then
            if grep -i "password.*default" "$config_file" > /dev/null || \
               grep -i "secret.*example" "$config_file" > /dev/null; then
                default_password_files+=("$config_file")
            fi
        fi
    done
    
    if [ ${#default_password_files[@]} -gt 0 ]; then
        log_warning "Potential default credentials in: ${default_password_files[*]}"
    else
        log_success "No obvious default credentials in configs"
    fi
}

# Generate SBOM (Software Bill of Materials)
generate_sbom() {
    log_info "Generating Software Bill of Materials..."
    
    local sbom_file="sbom-$(date +%Y%m%d).json"
    
    cat > "$sbom_file" << EOF
{
  "bomFormat": "CycloneDX",
  "specVersion": "1.4",
  "serialNumber": "urn:uuid:$(uuidgen || echo "blux-ecosystem-sbom")",
  "version": 1,
  "metadata": {
    "timestamp": "$(date -Iseconds)",
    "component": {
      "type": "application",
      "name": "blux-ecosystem",
      "version": "0.9.0-alpha",
      "description": "BLUX Ecosystem Hub"
    }
  },
  "components": [
    {
      "type": "application",
      "name": "blux-ecosystem",
      "version": "0.9.0-alpha",
      "description": "Gravitational hub for BLUX constellation"
    }
  ]
}
EOF

    log_success "SBOM generated: $sbom_file"
}

# Main security audit
main() {
    echo "🔒 BLUX Dependency Security Audit"
    echo "================================"
    
    log_info "Starting comprehensive security check..."
    
    # Run checks
    check_system_deps
    echo
    
    check_python_deps
    echo
    
    check_node_deps
    echo
    
    check_security_patterns
    echo
    
    check_config_security
    echo
    
    generate_sbom
    echo
    
    log_success "Security audit completed"
    log_info "Review warnings and address critical issues"
    
    # Final recommendations
    echo
    log_info "Recommended next steps:"
    echo "  1. Address any critical dependency vulnerabilities"
    echo "  2. Review security warnings in configuration"
    echo "  3. Update SBOM for production deployment"
    echo "  4. Run 'safety check' and 'npm audit' regularly"
}

# Parse arguments
case "${1:-}" in
    "--help" | "-h")
        echo "Usage: $0 [OPTIONS]"
        echo "BLUX Dependency Security Check"
        echo ""
        echo "Options:"
        echo "  --help    Show this help"
        echo "  --quick   Quick check only"
        echo ""
        echo "Performs comprehensive security audit of dependencies and configuration."
        exit 0
        ;;
    "--quick")
        log_info "Running quick security check..."
        check_system_deps
        check_security_patterns
        ;;
    *)
        main
        ;;
esac
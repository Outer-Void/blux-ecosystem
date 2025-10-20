#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# BLUX Ecosystem Bootstrap Script
# One-command development environment setup

echo "🚀 BLUX Ecosystem Bootstrap"
echo "==========================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    local missing=()
    
    # Check Git
    if ! command -v git &> /dev/null; then
        missing+=("git")
    fi
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        log_warning "Docker not found - some features will be limited"
    fi
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        missing+=("python3")
    fi
    
    # Check Node.js (optional)
    if ! command -v node &> /dev/null; then
        log_warning "Node.js not found - web components will be limited"
    fi
    
    if [ ${#missing[@]} -ne 0 ]; then
        log_error "Missing prerequisites: ${missing[*]}"
        log_info "Please install missing tools and run again"
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

# Setup directory structure
setup_directories() {
    log_info "Setting up directory structure..."
    
    local dirs=(
        "backups"
        "patches" 
        "logs"
        "tmp"
        "manifests"
        "config"
        "docs/examples"
        "docs/troubleshooting"
        "docs/deployment"
    )
    
    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            log_info "Created directory: $dir"
        fi
    done
    
    log_success "Directory structure ready"
}

# Make scripts executable
make_scripts_executable() {
    log_info "Making scripts executable..."
    
    if [ -d "scripts" ]; then
        chmod +x scripts/*.sh
        log_success "Scripts are now executable"
    else
        log_error "Scripts directory not found"
        exit 1
    fi
}

# Setup git hooks
setup_git_hooks() {
    log_info "Setting up Git hooks..."
    
    if command -v pre-commit &> /dev/null; then
        pre-commit install
        pre-commit install --hook-type commit-msg
        log_success "Git hooks installed"
    else
        log_warning "pre-commit not installed, skipping Git hooks"
        log_info "Install with: pip install pre-commit"
    fi
}

# Create default configuration
create_default_config() {
    log_info "Creating default configuration..."
    
    local config_dir="config"
    
    # Development configuration
    cat > "$config_dir/development.yaml" << 'EOF'
# BLUX Development Configuration
environment: development

logging:
  level: debug
  format: json
  file: logs/blux-dev.log

security:
  require_authentication: false
  sandbox_execution: true
  audit_all_operations: true

services:
  blux_reg:
    host: localhost
    port: 50050
    
  blux_guard:
    host: localhost  
    port: 50052
    
  blux_lite:
    host: localhost
    port: 50051
    
  blux_ca:
    host: localhost
    port: 50053

audit:
  path: ~/.config/blux/audit/
  rotation:
    max_size_mb: 100
    max_age_days: 7
EOF

    # Default environment file
    cat > ".env.example" << 'EOF'
# BLUX Environment Configuration
# Copy to .env and modify as needed

# Environment
BLUX_ENV=development

# Paths
BLUX_AUDIT_PATH=~/.config/blux/audit/
BLUX_LOG_PATH=~/.config/blux/logs/
BLUX_DATA_PATH=~/.config/blux/data/

# Service Endpoints
BLUX_REG_HOST=localhost:50050
BLUX_GUARD_HOST=localhost:50052
BLUX_LITE_HOST=localhost:50051
BLUX_CA_HOST=localhost:50053
BLUX_QUANTUM_HOST=localhost:50054
BLUX_COMMANDER_HOST=localhost:3000

# Security
BLUX_MASTER_KEY_PATH=~/.config/blux/keys/master.key

# Observability
JAEGER_ENDPOINT=http://localhost:14268/api/traces
EOF

    log_success "Default configuration created"
}

# Create initial manifests
create_manifests() {
    log_info "Creating initial manifests..."
    
    local manifests_dir="manifests"
    
    # Hub manifest
    cat > "$manifests_dir/hub.manifest.json" << 'EOF'
{
  "version": "0.9.0-alpha",
  "cluster": "blux-ecosystem",
  "release_date": "2025-10-20",
  "git_commit": "$(git rev-parse HEAD 2>/dev/null || echo 'unknown')",
  "services": {
    "blux-reg": {
      "version": "1.2.0",
      "endpoint": "localhost:50050",
      "capabilities": ["identity_issuance", "key_rotation"],
      "status": "required"
    },
    "blux-lite": {
      "version": "0.8.1", 
      "endpoint": "localhost:50051",
      "capabilities": ["orchestration", "doctrine_enforcement"],
      "status": "required"
    },
    "blux-guard": {
      "version": "1.1.0",
      "endpoint": "localhost:50052",
      "capabilities": ["security_enforcement", "audit_trail"],
      "status": "required"
    },
    "blux-ca": {
      "version": "0.8.0",
      "endpoint": "localhost:50053", 
      "capabilities": ["conscious_reflection", "context_enrichment"],
      "status": "optional"
    }
  },
  "doctrine": {
    "version": "1.0",
    "principles": [
      "reflection_over_reaction",
      "coordination_over_concentration", 
      "coherence_over_complexity",
      "principles_over_preferences"
    ]
  }
}
EOF

    # Doctrine policy
    cat > "$manifests_dir/policy.doctrine.json" << 'EOF'
{
  "doctrine_version": "1.0",
  "effective_date": "2025-10-20",
  "flags": {
    "require_reflection": true,
    "sandbox_all_operations": true,
    "audit_all_requests": true,
    "validate_all_signatures": true,
    "encrypt_all_data": true,
    "minimize_pii": true
  },
  "constraints": {
    "max_execution_time": "30s",
    "max_memory_mb": 512,
    "allowed_data_sources": ["internal", "approved_external"],
    "privacy_requirements": ["gdpr", "ccpa"]
  },
  "security": {
    "default_sandbox": "docker",
    "require_mtls": true,
    "key_rotation_days": 30,
    "audit_retention_days": 365
  }
}
EOF

    log_success "Initial manifests created"
}

# Run health check
run_health_check() {
    log_info "Running initial health check..."
    
    if [ -f "scripts/health-check.sh" ]; then
        ./scripts/health-check.sh --quick
    else
        log_warning "Health check script not available yet"
    fi
}

# Display completion message
show_completion() {
    echo
    log_success "🚀 BLUX Ecosystem bootstrap complete!"
    echo
    echo "Next steps:"
    echo "1. Review configuration:  cat config/development.yaml"
    echo "2. Copy environment file: cp .env.example .env"
    echo "3. Run health check:      ./scripts/health-check.sh"
    echo "4. Explore anchors:       ./scripts/anchor-list.sh"
    echo
    echo "Development workflow:"
    echo "  ./scripts/backup.sh --tag pre-changes"
    echo "  # Edit within anchors"
    echo "  ./scripts/health-check.sh"
    echo
    echo "Documentation:"
    echo "  README.md              - Overview and quick start"
    echo "  DEVELOPER_GUIDE.md     - Patch-first development"
    echo "  ARCHITECTURE.md        - System design"
    echo
    log_info "Happy coding! Remember: Reflection > Reaction"
}

# Main execution
main() {
    echo
    log_info "Starting BLUX Ecosystem bootstrap..."
    
    check_prerequisites
    setup_directories
    make_scripts_executable
    setup_git_hooks
    create_default_config
    create_manifests
    run_health_check
    show_completion
}

# Run main function
main "$@"
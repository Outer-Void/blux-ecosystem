# BLUX Configuration Guide

## Multi-Environment Setup

BLUX supports multiple deployment environments with consistent configuration patterns.

### Environment Detection

```bash
# Automatic environment detection (in order of precedence)
BLUX_ENV=production           # Explicit setting
.env file                     # Local override
NODE_ENV=production          # Fallback to Node.js standard
default: development         # Final fallback
```

## Core Configuration

### Environment Variables

```bash
# Environment & Deployment
export BLUX_ENV=production
export BLUX_DEPLOYMENT_REGION=us-west-2
export BLUX_CLUSTER_ID=blux-prod-01

# Paths & Storage
export BLUX_AUDIT_PATH=~/.config/blux/audit/
export BLUX_LOG_PATH=~/.config/blux/logs/
export BLUX_DATA_PATH=~/.config/blux/data/
export BLUX_CACHE_PATH=~/.config/blux/cache/

# Security
export BLUX_MASTER_KEY_PATH=~/.config/blux/keys/master.key
export BLUX_ENCRYPTION_KEY=$(cat ~/.config/blux/keys/encryption.key)
```

### Service Endpoints

```bash
# Development (Local)
export BLUX_REG_HOST=localhost:50050
export BLUX_GUARD_HOST=localhost:50052
export BLUX_LITE_HOST=localhost:50051
export BLUX_CA_HOST=localhost:50053
export BLUX_QUANTUM_HOST=localhost:50054
export BLUX_COMMANDER_HOST=localhost:3000

# Production (Cluster)
export BLUX_REG_HOST=reg.blux.example:443
export BLUX_GUARD_HOST=guard.blux.example:443
export BLUX_LITE_HOST=lite.blux.example:443
export BLUX_CA_HOST=ca.blux.example:443
```

## Configuration Manifests

### Hub Manifest (manifests/hub.manifest.json)

```json
{
  "version": "0.9.0-alpha",
  "cluster": "blux-ecosystem",
  "release_date": "2025-10-20",
  "services": {
    "blux-reg": {
      "version": "1.2.0",
      "endpoint": "https://reg.blux.example:443",
      "capabilities": ["identity_issuance", "key_rotation"]
    },
    "blux-lite": {
      "version": "0.8.1",
      "endpoint": "https://lite.blux.example:443",
      "capabilities": ["orchestration", "doctrine_enforcement"]
    }
  },
  "signature": "es512-..."
}
```

### Doctrine Policy (manifests/policy.doctrine.json)

```json
{
  "doctrine_version": "1.0",
  "effective_date": "2025-10-20",
  "flags": {
    "require_reflection": true,
    "sandbox_all_operations": true,
    "audit_all_requests": true,
    "validate_all_signatures": true,
    "encrypt_all_data": true
  },
  "constraints": {
    "max_execution_time": "30s",
    "max_memory_mb": 512,
    "allowed_data_sources": ["internal", "approved_external"]
  }
}
```

## Environment-Specific Configs

### Development

```yaml
# config/development.yaml
logging:
  level: debug
  format: json
  
security:
  require_authentication: false
  sandbox_execution: true
  
performance:
  cache_ttl: 5m
  query_timeout: 30s
```

### Production

```yaml
# config/production.yaml
logging:
  level: info
  format: json
  
security:
  require_authentication: true
  sandbox_execution: true
  require_mtls: true
  
performance:
  cache_ttl: 1h
  query_timeout: 10s
```

### Validation & Health Checks

```bash
# Validate configuration
python tools/config-validator.py --env production

# Check service health
./scripts/health-check.sh --full

# Verify security posture
./tools/dependency-check.sh --audit
```

## Dynamic Configuration

BLUX supports hot-reload for certain configuration changes:

```bash
# Reload doctrine without restart
curl -X POST https://lite.blux.example:443/admin/doctrine/reload

# Update feature flags
curl -X PATCH https://lite.blux.example:443/admin/config \
  -d '{"feature_x": true, "rate_limit": 1000}'
```

---

Configuration is choreography.  (( • ))

---
# BLUX Developer Guide

## Patch-First Development Philosophy

We change complex systems gently: **diffs over rewrites**, **anchors over guesses**, **backups before edits**.

## Development Environment

### Quick Start
```bash
# Clone and bootstrap
git clone --recurse-submodules https://github.com/Outer-Void/blux-ecosystem.git
cd blux-ecosystem
./scripts/bootstrap.sh

# Verify setup
./scripts/health-check.sh
```

## Prerequisites

· Git with commit signing
· Python 3.9+ or Node.js 18+
· Docker for service sandboxing
· jq for JSON processing

## Anchor-Based Development

What are Anchors?

Anchors are named code blocks that localize and document changes:

```python
# ANCHOR: feature_authentication
def authenticate_user(request):
    # Your changes here
    pass
# ANCHOR_END: feature_authentication
```

Finding Anchors

```bash
# List all available anchors
./scripts/anchor-list.sh

# Search for specific anchors
./scripts/anchor-list.sh | grep -i auth
```

## Development Workflow

1. Branch Strategy

```bash
# Feature branches
git checkout -b feature/authentication-enhancement

# Hotfix branches  
git checkout -b hotfix/critical-security-issue
```

2. State Preservation

```bash
# Create backup before changes
./scripts/backup.sh --tag pre-auth-changes

# View backup contents
ls -la backups/pre-auth-changes/
```

3. Anchor-Based Editing

Edit only within anchor blocks:

```python
# ANCHOR: route_selection
def select_route(context):
    # OLD: simple round-robin
    # NEW: doctrine-aware routing
    if context.doctrine.require_reflection:
        return select_reflective_route(context)
    return select_direct_route(context)
# ANCHOR_END: route_selection
```

4. Patch Generation

```bash
# Generate patch file
git add .
git diff --cached > patches/$(date +%Y-%m-%d)-auth-enhancement.patch

# Review patch
git apply --stat patches/2025-10-20-auth-enhancement.patch
```

5. Testing & Validation

```bash
# Run unit tests
pytest tests/ -v

# Security scan
./tools/dependency-check.sh

# Configuration validation
python tools/config-validator.py

# Health check
./scripts/health-check.sh
```

6. Pull Request

```bash
# Commit with signed-off-by
git commit -S -m "feat: enhance authentication with doctrine awareness

- Added reflective routing for high-sensitivity operations
- Maintained backward compatibility
- Updated audit trails

Anchors: route_selection, security_context
Signed-off-by: Your Name <email@example.com>"

# Create PR
gh pr create --title "feat: authentication enhancement" --body-file pr_description.md
```

## PR Description Template

```markdown
## Change Summary
Brief description of what changed and why.

## Anchors Modified
- `route_selection`: Enhanced with doctrine awareness
- `security_context`: Added reflection requirements

## Testing Performed
- [x] Unit tests updated
- [x] Integration tests passing
- [x] Security scan clean
- [x] Health check passes

## Audit Impact
- New audit events: `route.reflection_required`
- Modified events: `route.selected`

## Backward Compatibility
- [x] Fully backward compatible
- [ ] Requires migration (describe)
- [ ] Breaking change (justify)
```

## Troubleshooting

### Common Issues

Anchor Not Found

```bash
ERROR: Anchor "feature_x" not found in codebase
```

Solution: Run ./scripts/anchor-list.sh to see available anchors

Patch Apply Failure

```bash
error: patch failed: src/core.py:45
```

Solution: Use ./scripts/restore.sh backups/pre-changes/ and re-apply carefully

Health Check Failures

```bash
[FAIL] Service blux-lite not responding
```

Solution: Check if all services are running with docker ps

### Debug Mode

```bash
# Enable verbose logging
export BLUX_LOG_LEVEL=debug

# Start services in debug mode
./scripts/bootstrap.sh --debug

# Attach debugger to specific service
./scripts/debug-service.sh blux-lite
```

## Performance Considerations

Before Committing

```bash
# Performance baseline
./scripts/performance-baseline.sh

# Memory usage check
./tools/memory-profiler.sh

# Audit trail impact
python tools/audit-analyzer.py --performance
```

## Security Checklist

· No secrets in code or patches
· All inputs validated and sanitized
· Audit trails updated appropriately
· Doctrine flags respected
· Security context maintained

Make each rewrite traceable.  (( • ))

---

Stuck? Check docs/troubleshooting/common-issues.md or open a discussion.

---

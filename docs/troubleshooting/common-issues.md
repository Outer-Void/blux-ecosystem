# Common Issues & Solutions

## Quick Reference

| Symptom | Likely Cause | Solution |
|---------|--------------|----------|
| Service won't start | Missing dependencies | Run `./scripts/bootstrap.sh` |
| Health check fails | Configuration issues | Run `python tools/config-validator.py` |
| Audit trails missing | Path permissions | Check `BLUX_AUDIT_PATH` permissions |
| Service connection refused | Services not running | Check service status with `./scripts/health-check.sh` |

## Service Issues

### blux-lite Won't Start

**Symptoms**:
- Error: "Failed to connect to blux-reg"
- Service exits immediately
- Health check fails

**Solutions**:

1. **Check service dependencies**:
```bash
# Verify all services are running
./scripts/health-check.sh --no-config

# Check individual service health
curl http://localhost:50050/health  # blux-reg
curl http://localhost:50052/health  # blux-guard
```

2. Verify configuration:

```bash
# Check environment variables
echo $BLUX_REG_HOST
echo $BLUX_GUARD_HOST

# Validate configuration
python tools/config-validator.py
```

3. Check service logs:

```bash
# If using Docker
docker-compose logs blux-lite

# If running directly
journalctl -u blux-lite  # systemd
```

### blux-guard Authentication Failures

Symptoms:

· "Authentication failed" errors
· "Invalid signature" messages
· Service communication blocked

Solutions:

1. Verify identity service:

```bash
# Check blux-reg health
curl http://localhost:50050/health

# Test token issuance
curl -X POST http://localhost:50050/v1/tokens \
  -H "Content-Type: application/json" \
  -d '{"service": "blux-lite"}'
```

2. Check key material:

```bash
# Verify keys exist
ls -la ~/.config/blux/keys/

# Check key permissions (should be 600)
stat -c "%a %n" ~/.config/blux/keys/*.key
```

3. Regenerate keys if needed:

```bash
# Backup existing keys
./scripts/backup.sh --tag pre-key-rotation

# Regenerate (implementation specific)
blux-reg key rotate --service blux-lite
```

## Database Issues

### Connection Pool Exhausted

Symptoms:

· "Too many connections" errors
· Service slowdowns
· Database connection timeouts

Solutions:

1. Adjust connection pool settings:

```yaml
# config/production.yaml
database:
  pool_size: 20
  max_overflow: 10
  pool_timeout: 30
  pool_recycle: 3600
```

2. Monitor database connections:

```sql
-- PostgreSQL
SELECT count(*) FROM pg_stat_activity;

-- Show connections by application
SELECT application_name, count(*) 
FROM pg_stat_activity 
GROUP BY application_name;
```

3. Implement connection cleanup:

```python
# Ensure proper connection handling
try:
    # Use connection
    result = db.execute(query)
finally:
    # Always return to pool
    db.close_connection()
```

### Migration Failures

Symptoms:

· "Migration version conflict" errors
· Database schema out of sync
· Service startup failures

Solutions:

1. Check migration status:

```bash
# Show current migration version
alembic current

# Show migration history
alembic history --verbose
```

2. Resolve conflicts:

```bash
# Create backup before migration
./scripts/backup.sh --tag pre-migration

# Attempt automatic resolution
alembic upgrade head

# If conflicts persist, manual intervention may be needed
alembic stamp head  # Mark current state
```

3. Rollback if needed:

```bash
# Rollback one migration
alembic downgrade -1

# Rollback to specific version
alembic downgrade <version>
```

## Performance Issues

### High Memory Usage

Symptoms:

· Services getting OOM killed
· System slowdowns
· High swap usage

Solutions:

1. Identify memory leaks:

```bash
# Monitor memory usage
docker stats

# Profile Python memory
python -m memory_profiler script.py
```

2. Adjust resource limits:

```yaml
# Kubernetes resources
resources:
  requests:
    memory: "512Mi"
    cpu: "500m"
  limits:
    memory: "1Gi" 
    cpu: "1000m"
```

3. Optimize data structures:

```python
# Use generators for large datasets
def process_large_dataset():
    for item in large_dataset:
        yield process_item(item)

# Clear caches periodically
import gc
gc.collect()
```

### Slow Response Times

Symptoms:

· High latency on API calls
· Timeout errors
· Queue buildup

Solutions:

1. Identify bottlenecks:

```bash
# Check database performance
EXPLAIN ANALYZE SELECT * FROM large_table;

# Monitor Redis performance
redis-cli info stats | grep -E "(instantaneous_ops_per_sec|used_memory)"
```

2. Optimize queries:

```sql
-- Add missing indexes
CREATE INDEX CONCURRENTLY idx_tasks_status ON tasks(status);
CREATE INDEX CONCURRENTLY idx_audit_timestamp ON audit_entries(timestamp);
```

3. Implement caching:

```python
# Redis caching example
import redis
r = redis.Redis()

def get_cached_data(key):
    cached = r.get(key)
    if cached:
        return json.loads(cached)
    
    # Compute and cache
    data = compute_expensive_operation()
    r.setex(key, 3600, json.dumps(data))  # Cache for 1 hour
    return data
```

## Security Issues

### Certificate Problems

Symptoms:

· TLS handshake failures
· "Certificate expired" errors
· mTLS connection rejections

Solutions:

1. Check certificate validity:

```bash
# Check expiration
openssl x509 -in certificate.crt -noout -dates

# Verify certificate chain
openssl verify -CAfile ca.crt certificate.crt
```

2. Rotate certificates:

```bash
# Generate new certificates
openssl req -new -newkey rsa:4096 -nodes -keyout new.key -out new.csr

# Distribute to services
# Update configuration with new certificate paths
```

3. Update trust stores:

```bash
# Update CA bundle
cp new-ca.crt /etc/ssl/certs/
update-ca-certificates
```

### Audit Trail Issues

Symptoms:

· Missing audit entries
· "Audit write failed" errors
· Audit file permission issues

Solutions:

1. Verify audit configuration:

```bash
# Check audit path exists and is writable
ls -la $BLUX_AUDIT_PATH
touch $BLUX_AUDIT_PATH/test.txt && rm $BLUX_AUDIT_PATH/test.txt

# Check disk space
df -h $BLUX_AUDIT_PATH
```

2. Fix permissions:

```bash
# Set correct permissions
chmod 755 $BLUX_AUDIT_PATH
chown blux:blux $BLUX_AUDIT_PATH

# Fix existing audit files
chmod 644 $BLUX_AUDIT_PATH/*.jsonl
```

3. Recover from audit failures:

```python
# Implement audit fallback
try:
    write_audit_entry(entry)
except IOError as e:
    # Fallback to system log
    logging.error(f"Audit write failed: {e}")
    # Queue for retry
    queue_audit_retry(entry)
```

## Network Issues

### Service Discovery Problems

Symptoms:

· "Service not found" errors
· Inter-service communication failures
· DNS resolution issues

Solutions:

1. Verify service registration:

```bash
# Check if services are registered
curl http://localhost:50050/v1/services

# Test service connectivity
nc -zv blux-reg 50050
nc -zv blux-guard 50052
```

2. Check DNS configuration:

```bash
# Test DNS resolution
nslookup blux-reg
dig blux-guard

# Check /etc/hosts for overrides
cat /etc/hosts
```

3. Verify network policies:

```yaml
# Kubernetes network policy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: blux-internal
spec:
  podSelector:
    matchLabels:
      app: blux
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: blux
```

### Firewall and Port Issues

Symptoms:

· Connection timeouts
· "Connection refused" errors
· Port binding failures

Solutions:

1. Check port availability:

```bash
# Check if ports are in use
netstat -tulpn | grep :50050
ss -tulpn | grep :50050

# Check firewall rules
iptables -L
ufw status  # Ubuntu
```

2. Open required ports:

```bash
# Open ports in firewall
ufw allow 50050/tcp  # blux-reg
ufw allow 50051/tcp  # blux-lite  
ufw allow 50052/tcp  # blux-guard
ufw allow 50053/tcp  # blux-ca
```

3. Verify port binding:

```python
# Test port binding in code
import socket

def check_port_available(port):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        return s.connect_ex(('localhost', port)) != 0
```

## Configuration Issues

### Environment Variable Problems

Symptoms:

· "Required environment variable missing"
· Configuration validation failures
· Service startup errors

Solutions:

1. Validate environment setup:

```bash
# Check all required variables
python tools/config-validator.py --check

# Source environment file
source .env

# Verify variable values
env | grep BLUX_
```

2. Set default values:

```python
import os

# Use defaults for optional variables
database_url = os.getenv('DATABASE_URL', 'sqlite:///./default.db')
log_level = os.getenv('LOG_LEVEL', 'info')
```

3. Configuration validation:

```python
from pydantic import BaseSettings, validator

class Settings(BaseSettings):
    database_url: str
    log_level: str = 'info'
    
    @validator('database_url')
    def validate_database_url(cls, v):
        if not v.startswith(('sqlite://', 'postgresql://')):
            raise ValueError('Invalid database URL')
        return v
```

### File Permission Issues

Symptoms:

· "Permission denied" errors
· File creation failures
· Audit or log write errors

Solutions:

1. Check file permissions:

```bash
# Verify directory permissions
ls -la /path/to/blux/data/
stat /path/to/blux/data/

# Check user permissions
id
whoami
```

2. Fix permissions:

```bash
# Set correct ownership
chown -R blux:blux /path/to/blux/data/

# Set secure permissions
chmod 755 /path/to/blux/data/
chmod 600 /path/to/blux/data/*.key  # Private keys
chmod 644 /path/to/blux/data/*.jsonl  # Audit files
```

3. Use appropriate users:

```dockerfile
# Dockerfile example
FROM python:3.9-slim

# Create non-root user
RUN useradd -m -u 1000 blux
USER blux

# Copy application files
COPY --chown=blux:blux . /app
```

### Recovery Procedures

Service Recovery

1. Identify failed service:

```bash
./scripts/health-check.sh
```

2. Check service status:

```bash
systemctl status blux-lite  # systemd
docker-compose ps           # Docker
kubectl get pods -n blux    # Kubernetes
```

3. Restart service:

```bash
systemctl restart blux-lite
docker-compose restart blux-lite
kubectl rollout restart deployment/blux-lite -n blux
```

Data Recovery

1. Identify data loss:

```bash
# Check audit trail continuity
python tools/audit-analyzer.py --verify-continuity

# Verify database integrity
pg_checkdb blux_prod  # PostgreSQL
```

2. Restore from backup:

```bash
# Restore database
pg_restore -d blux_prod backup_file.dump

# Restore audit trails
./scripts/restore.sh backups/backup-20251020/
```

3. Verify recovery:

```bash
# Run comprehensive health check
./scripts/health-check.sh

# Verify data integrity
python tools/audit-analyzer.py --validate
```

---

Every problem contains its solution; we just need to look clearly.  (( • ))

Still stuck? Check the Debug Guide or open an issue.

---
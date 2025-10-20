# Production Deployment Guide

## Overview

This guide covers deploying BLUX Ecosystem in production environments with high availability, security, and performance requirements.

## Architecture

### Production Topology
```mermaid
graph TB
    subgraph "Load Balancer Layer"
        LB[Load Balancer]
    end
    
    subgraph "Application Layer"
        Lite1[blux-lite 1]
        Lite2[blux-lite 2]
        Guard1[blux-guard 1]
        Guard2[blux-guard 2]
    end
    
    subgraph "Data Layer"
        DB[(PostgreSQL)]
        Redis[(Redis Cluster)]
        Audit[Audit Storage]
    end
    
    subgraph "Identity Layer"
        Reg1[blux-reg 1]
        Reg2[blux-reg 2]
    end
    
    LB --> Lite1
    LB --> Lite2
    Lite1 --> Guard1
    Lite2 --> Guard2
    Guard1 --> Reg1
    Guard2 --> Reg2
    Lite1 --> DB
    Lite2 --> DB
    Lite1 --> Redis
    Lite2 --> Redis
    Guard1 --> Audit
    Guard2 --> Audit
```

Prerequisites

Infrastructure Requirements

· Kubernetes cluster or Docker Swarm
· PostgreSQL 13+ database cluster
· Redis 6+ cluster for caching
· Object storage for audit trails (S3, GCS, etc.)
· Load balancer with SSL termination
· Monitoring stack (Prometheus, Grafana)

Security Requirements

· TLS certificates for all endpoints
· Firewall rules limiting internal traffic
· Secret management (HashiCorp Vault, AWS Secrets Manager)
· Network policies for service isolation

Configuration

Production Environment

```bash
# Environment variables
export BLUX_ENV=production
export BLUX_CLUSTER_ID=blux-prod-01
export BLUX_DEPLOYMENT_REGION=us-west-2

# Database
export DATABASE_URL=postgresql://user:pass@db-host:5432/blux_prod
export REDIS_URL=redis://redis-host:6379/0

# Security
export BLUX_MASTER_KEY=$(vault read -field=key secret/blux/master)
export JWT_SECRET_KEY=$(vault read -field=secret secret/blux/jwt)

# Services
export BLUX_REG_HOST=reg.blux.example:443
export BLUX_GUARD_HOST=guard.blux.example:443
export BLUX_LITE_HOST=lite.blux.example:443
export BLUX_CA_HOST=ca.blux.example:443
```

Production Configuration

```yaml
# config/production.yaml
environment: production

logging:
  level: info
  format: json
  file: /var/log/blux/blux.log
  
security:
  require_authentication: true
  require_mtls: true
  sandbox_execution: true
  audit_all_operations: true
  
database:
  url: ${DATABASE_URL}
  pool_size: 20
  max_overflow: 30
  pool_timeout: 30
  pool_recycle: 3600
  
cache:
  url: ${REDIS_URL}
  key_prefix: blux_prod
  default_ttl: 3600

services:
  blux_reg:
    host: reg.blux.example
    port: 443
    tls: true
    
  blux_guard:
    host: guard.blux.example  
    port: 443
    tls: true
    
  blux_lite:
    host: lite.blux.example
    port: 443
    tls: true

audit:
  storage:
    type: s3
    bucket: blux-audit-trails
    region: us-west-2
  retention_days: 365
  encryption: true
```

Kubernetes Deployment

Namespace Configuration

```yaml
# k8s/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: blux-production
  labels:
    name: blux-production
```

Secret Management

```yaml
# k8s/secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: blux-secrets
  namespace: blux-production
type: Opaque
data:
  database-url: <base64-encoded>
  redis-url: <base64-encoded>
  master-key: <base64-encoded>
  jwt-secret: <base64-encoded>
```

blux-lite Deployment

```yaml
# k8s/blux-lite-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: blux-lite
  namespace: blux-production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: blux-lite
  template:
    metadata:
      labels:
        app: blux-lite
    spec:
      containers:
      - name: blux-lite
        image: blux/lite:1.0.0
        ports:
        - containerPort: 8080
        env:
        - name: BLUX_ENV
          value: "production"
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: blux-secrets
              key: database-url
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
```

Service Configuration

```yaml
# k8s/blux-lite-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: blux-lite
  namespace: blux-production
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "external"
    service.beta.kubernetes.io/aws-load-balancer-ssl-cert: "arn:aws:acm:..."
spec:
  selector:
    app: blux-lite
  ports:
  - port: 443
    targetPort: 8080
    protocol: TCP
  type: LoadBalancer
```

Database Setup

PostgreSQL Configuration

```sql
-- Create database and user
CREATE DATABASE blux_prod;
CREATE USER blux_user WITH PASSWORD 'secure_password';
GRANT ALL PRIVILEGES ON DATABASE blux_prod TO blux_user;

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
```

Database Migration

```bash
# Run migrations
alembic upgrade head

# Verify migration
alembic current

# Create backup before major updates
pg_dump blux_prod > backup-$(date +%Y%m%d).sql
```

Security Hardening

Network Policies

```yaml
# k8s/network-policies.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: blux-internal
  namespace: blux-production
spec:
  podSelector:
    matchLabels:
      app: blux
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: blux
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: blux
    ports:
    - protocol: TCP
      port: 8080
  - to:
    - namespaceSelector: {}
    ports:
    - protocol: TCP
      port: 5432  # PostgreSQL
    - protocol: TCP  
      port: 6379  # Redis
```

mTLS Configuration

```yaml
# istio/mtls.yaml
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: blux-mtls
  namespace: blux-production
spec:
  mtls:
    mode: STRICT
```

Monitoring & Observability

Prometheus Configuration

```yaml
# monitoring/service-monitor.yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: blux-monitor
  namespace: blux-production
spec:
  selector:
    matchLabels:
      app: blux
  endpoints:
  - port: http-metrics
    interval: 30s
    path: /metrics
```

Custom Metrics

```python
# Example custom metric
from prometheus_client import Counter, Histogram

requests_total = Counter('blux_requests_total', 'Total requests', ['service', 'status'])
request_duration = Histogram('blux_request_duration_seconds', 'Request duration', ['service'])
```

Alerting Rules

```yaml
# monitoring/alerts.yaml
groups:
- name: blux.rules
  rules:
  - alert: BLUXServiceDown
    expr: up{job="blux-lite"} == 0
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "BLUX service down"
      description: "Service {{ $labels.instance }} is down."
      
  - alert: HighErrorRate
    expr: rate(blux_requests_total{status=~"5.."}[5m]) > 0.1
    for: 2m
    labels:
      severity: warning
```

Backup & Disaster Recovery

Database Backups

```bash
#!/bin/bash
# backup-database.sh
DATE=$(date +%Y%m%d-%H%M%S)
pg_dump blux_prod | gzip > /backups/blux-db-$DATE.sql.gz

# Retain 7 daily, 4 weekly backups
find /backups -name "blux-db-*.sql.gz" -mtime +7 -delete
```

Audit Trail Backup

```python
# S3 lifecycle policy for audit trails
{
  "Rules": [
    {
      "ID": "MoveToGlacier",
      "Status": "Enabled", 
      "Prefix": "audit/",
      "Transition": {
        "Days": 30,
        "StorageClass": "GLACIER"
      }
    }
  ]
}
```

Disaster Recovery Plan

1. Identify failure - Monitoring alerts
2. Failover - Route traffic to standby region
3. Restore - Database and service restoration
4. Validation - Service and data integrity checks
5. Failback - Return to primary region

Performance Optimization

Caching Strategy

```yaml
# Redis configuration
cache:
  default_ttl: 3600
  key_patterns:
    user_sessions: "session:*"
    task_results: "task:*"
    policy_cache: "policy:*"
```

Database Optimization

```sql
-- Critical indexes
CREATE INDEX CONCURRENTLY idx_audit_timestamp ON audit_entries(timestamp);
CREATE INDEX CONCURRENTLY idx_tasks_status ON tasks(status);
CREATE INDEX CONCURRENTLY idx_identity_active ON identities(is_active);
```

Resource Limits

```yaml
# Resource recommendations
resources:
  blux-lite:
    requests:
      memory: "512Mi" 
      cpu: "500m"
    limits:
      memory: "1Gi"
      cpu: "1000m"
      
  blux-guard:
    requests:
      memory: "256Mi"
      cpu: "250m" 
    limits:
      memory: "512Mi"
      cpu: "500m"
```

Deployment Checklist

Pre-Deployment

· Security scan completed
· Performance testing passed
· Backup procedures verified
· Rollback plan documented
· Team communication sent

During Deployment

· Gradual traffic shift
· Health checks passing
· Error rates monitored
· Performance metrics stable

Post-Deployment

· Full functionality verified
· Security controls active
· Monitoring alerts configured
· Documentation updated

Troubleshooting

Common Issues

High Memory Usage

```bash
# Check memory usage
kubectl top pods -n blux-production

# Analyze memory profiles
kubectl exec -it blux-lite-pod -- python -m memory_profiler script.py
```

Database Connection Issues

```bash
# Check database connectivity
kubectl exec -it blux-lite-pod -- nc -zv db-host 5432

# Verify connection pool
kubectl logs blux-lite-pod | grep -i connection
```

Certificate Issues

```bash
# Check certificate validity
openssl x509 -in certificate.crt -text -noout

# Verify TLS handshake
openssl s_client -connect lite.blux.example:443
```

---

Production is where theory meets reality.  (( • ))

Next: Kubernetes Deployment Guide

---
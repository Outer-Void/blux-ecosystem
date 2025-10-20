# Kubernetes Deployment Guide

## Overview

Complete guide for deploying BLUX Ecosystem on Kubernetes with production-grade configurations.

## Cluster Requirements

### Minimum Requirements
- **Kubernetes**: 1.24+
- **CNI Plugin**: Calico, Cilium, or Weave
- **Storage**: CSI-compatible storage class
- **Load Balancer**: Cloud provider or MetalLB

### Recommended Setup
- **Nodes**: 3+ worker nodes
- **CPU**: 4+ cores per node
- **Memory**: 16GB+ RAM per node
- **Storage**: 100GB+ per node

## Namespace Setup

```yaml
# k8s/00-namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: blux
  labels:
    name: blux
    environment: production
```

Configuration Management

ConfigMap for Environment

```yaml
# k8s/01-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: blux-config
  namespace: blux
data:
  environment: "production"
  log-level: "info"
  database-url: "postgresql://blux-user:@blux-postgres:5432/blux"
  redis-url: "redis://blux-redis:6379"
```

Secrets Management

```yaml
# k8s/02-secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: blux-secrets
  namespace: blux
type: Opaque
data:
  # Base64 encoded values
  database-password: <base64-encoded-password>
  jwt-secret: <base64-encoded-secret>
  master-key: <base64-encoded-key>
```

Database Deployment

PostgreSQL StatefulSet

```yaml
# k8s/10-postgresql.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: blux-postgres
  namespace: blux
spec:
  serviceName: blux-postgres
  replicas: 1
  selector:
    matchLabels:
      app: blux-postgres
  template:
    metadata:
      labels:
        app: blux-postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15
        env:
        - name: POSTGRES_DB
          value: "blux"
        - name: POSTGRES_USER
          value: "blux-user"
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: blux-secrets
              key: database-password
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: postgres-data
          mountPath: /var/lib/postgresql/data
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
        livenessProbe:
          exec:
            command: ["pg_isready", "-U", "blux-user"]
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          exec:
            command: ["pg_isready", "-U", "blux-user"]
          initialDelaySeconds: 5
          periodSeconds: 5
  volumeClaimTemplates:
  - metadata:
      name: postgres-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: "fast-ssd"
      resources:
        requests:
          storage: "50Gi"
```

PostgreSQL Service

```yaml
# k8s/11-postgres-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: blux-postgres
  namespace: blux
spec:
  selector:
    app: blux-postgres
  ports:
  - port: 5432
    targetPort: 5432
  clusterIP: None  # Headless service for StatefulSet
```

Redis Deployment

Redis Deployment

```yaml
# k8s/20-redis.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: blux-redis
  namespace: blux
spec:
  replicas: 1
  selector:
    matchLabels:
      app: blux-redis
  template:
    metadata:
      labels:
        app: blux-redis
    spec:
      containers:
      - name: redis
        image: redis:7-alpine
        command: ["redis-server"]
        args: ["--appendonly", "yes"]
        ports:
        - containerPort: 6379
        volumeMounts:
        - name: redis-data
          mountPath: /data
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
        livenessProbe:
          exec:
            command: ["redis-cli", "ping"]
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          exec:
            command: ["redis-cli", "ping"]
          initialDelaySeconds: 5
          periodSeconds: 5
      volumes:
      - name: redis-data
        persistentVolumeClaim:
          claimName: redis-pvc
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: redis-pvc
  namespace: blux
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: fast-ssd
  resources:
    requests:
      storage: "10Gi"
```

Redis Service

```yaml
# k8s/21-redis-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: blux-redis
  namespace: blux
spec:
  selector:
    app: blux-redis
  ports:
  - port: 6379
    targetPort: 6379
```

BLUX Services Deployment

blux-reg Deployment

```yaml
# k8s/30-blux-reg.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: blux-reg
  namespace: blux
spec:
  replicas: 2
  selector:
    matchLabels:
      app: blux-reg
  template:
    metadata:
      labels:
        app: blux-reg
    spec:
      containers:
      - name: blux-reg
        image: blux/reg:1.0.0
        ports:
        - containerPort: 8080
        env:
        - name: BLUX_ENV
          valueFrom:
            configMapKeyRef:
              name: blux-config
              key: environment
        - name: DATABASE_URL
          valueFrom:
            configMapKeyRef:
              name: blux-config
              key: database-url
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: blux-secrets
              key: jwt-secret
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

blux-reg Service

```yaml
# k8s/31-blux-reg-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: blux-reg
  namespace: blux
spec:
  selector:
    app: blux-reg
  ports:
  - port: 80
    targetPort: 8080
    name: http
```

blux-guard Deployment

```yaml
# k8s/40-blux-guard.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: blux-guard
  namespace: blux
spec:
  replicas: 2
  selector:
    matchLabels:
      app: blux-guard
  template:
    metadata:
      labels:
        app: blux-guard
    spec:
      containers:
      - name: blux-guard
        image: blux/guard:1.0.0
        ports:
        - containerPort: 8080
        env:
        - name: BLUX_ENV
          valueFrom:
            configMapKeyRef:
              name: blux-config
              key: environment
        - name: REDIS_URL
          valueFrom:
            configMapKeyRef:
              name: blux-config
              key: redis-url
        - name: MASTER_KEY
          valueFrom:
            secretKeyRef:
              name: blux-secrets
              key: master-key
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
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

blux-lite Deployment

```yaml
# k8s/50-blux-lite.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: blux-lite
  namespace: blux
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
          valueFrom:
            configMapKeyRef:
              name: blux-config
              key: environment
        - name: DATABASE_URL
          valueFrom:
            configMapKeyRef:
              name: blux-config
              key: database-url
        - name: REDIS_URL
          valueFrom:
            configMapKeyRef:
              name: blux-config
              key: redis-url
        - name: BLUX_REG_HOST
          value: "blux-reg"
        - name: BLUX_GUARD_HOST
          value: "blux-guard"
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
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

Ingress Configuration

NGINX Ingress

```yaml
# k8s/60-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: blux-ingress
  namespace: blux
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  tls:
  - hosts:
    - lite.blux.example
    - reg.blux.example
    - guard.blux.example
    secretName: blux-tls
  rules:
  - host: lite.blux.example
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: blux-lite
            port:
              number: 80
  - host: reg.blux.example
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: blux-reg
            port:
              number: 80
  - host: guard.blux.example
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: blux-guard
            port:
              number: 80
```

Network Policies

Internal Communication

```yaml
# k8s/70-network-policies.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: blux-internal
  namespace: blux
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
          app: blux-postgres
    ports:
    - protocol: TCP
      port: 5432
  - to:
    - podSelector:
        matchLabels:
          app: blux-redis
    ports:
    - protocol: TCP
      port: 6379
```

Monitoring & Logging

ServiceMonitor for Prometheus

```yaml
# k8s/80-monitoring.yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: blux-monitor
  namespace: blux
spec:
  selector:
    matchLabels:
      app: blux
  endpoints:
  - port: http
    interval: 30s
    path: /metrics
```

Pod Disruption Budget

```yaml
# k8s/81-pdb.yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: blux-lite-pdb
  namespace: blux
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: blux-lite
```

Deployment Scripts

Apply All Manifests

```bash
#!/bin/bash
# deploy.sh

echo "Deploying BLUX Ecosystem to Kubernetes..."

# Apply namespace
kubectl apply -f k8s/00-namespace.yaml

# Apply configurations
kubectl apply -f k8s/01-configmap.yaml
kubectl apply -f k8s/02-secrets.yaml

# Deploy databases
kubectl apply -f k8s/10-postgresql.yaml
kubectl apply -f k8s/11-postgres-service.yaml
kubectl apply -f k8s/20-redis.yaml
kubectl apply -f k8s/21-redis-service.yaml

# Wait for databases
kubectl wait --for=condition=ready pod -l app=blux-postgres -n blux --timeout=300s
kubectl wait --for=condition=ready pod -l app=blux-redis -n blux --timeout=300s

# Deploy BLUX services
kubectl apply -f k8s/30-blux-reg.yaml
kubectl apply -f k8s/31-blux-reg-service.yaml
kubectl apply -f k8s/40-blux-guard.yaml
kubectl apply -f k8s/41-blux-guard-service.yaml
kubectl apply -f k8s/50-blux-lite.yaml
kubectl apply -f k8s/51-blux-lite-service.yaml

# Apply network policies and ingress
kubectl apply -f k8s/70-network-policies.yaml
kubectl apply -f k8s/60-ingress.yaml

# Apply monitoring
kubectl apply -f k8s/80-monitoring.yaml
kubectl apply -f k8s/81-pdb.yaml

echo "Deployment complete!"
echo "Check status with: kubectl get all -n blux"
```

Health Check

```bash
#!/bin/bash
# health-check.sh

echo "Checking BLUX deployment health..."

# Check pods
kubectl get pods -n blux

# Check services
kubectl get services -n blux

# Check ingress
kubectl get ingress -n blux

# Check pod status
kubectl wait --for=condition=ready pod -l app=blux -n blux --timeout=60s

# Test service endpoints
kubectl port-forward -n blux service/blux-lite 8080:80 &
sleep 5
curl -f http://localhost:8080/health
pkill -f "kubectl port-forward"

echo "Health check complete!"
```

Troubleshooting

Common Issues

Pod CrashLoopBackOff

```bash
# Check pod logs
kubectl logs -n blux deployment/blux-lite

# Check events
kubectl get events -n blux --sort-by=.lastTimestamp

# Check resource limits
kubectl describe pod -n blux -l app=blux-lite
```

Database Connection Issues

```bash
# Check database connectivity
kubectl exec -n blux deployment/blux-lite -- nc -zv blux-postgres 5432

# Check database logs
kubectl logs -n blux statefulset/blux-postgres
```

Ingress Issues

```bash
# Check ingress status
kubectl describe ingress -n blux blux-ingress

# Check ingress controller logs
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
```

Performance Optimization

Horizontal Pod Autoscaling

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: blux-lite-hpa
  namespace: blux
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: blux-lite
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

---

Kubernetes turns infrastructure into code.  (( • ))

---
# Debug Guide

## Debugging Philosophy

> *"The most effective debugging tool is still careful thought, coupled with judiciously placed print statements."* — Brian Kernighan

BLUX embraces systematic debugging through observation, hypothesis, and verification.

## Debugging Levels

### Level 1: Quick Diagnostics
```bash
# Basic system check
./scripts/health-check.sh --quick

# Service status
docker-compose ps
kubectl get pods -n blux

# Resource usage
docker stats
kubectl top pods -n blux
```

Level 2: Log Analysis

```bash
# Follow all logs
docker-compose logs -f
kubectl logs -f deployment/blux-lite -n blux

# Search for errors
grep -r "ERROR" logs/
jq 'select(.level == "ERROR")' logs/*.json

# Structured log analysis
jq -r '"\(.timestamp) \(.level) \(.message)"' logs/app.json | less
```

Level 3: Deep Investigation

```python
# Interactive debugging
import pdb; pdb.set_trace()

# Performance profiling
import cProfile
cProfile.run('my_function()')

# Memory profiling
from guppy import hpy
h = hpy()
print(h.heap())
```

Debugging Tools

Built-in Tools

Health Check Deep Dive

```bash
# Verbose health check
./scripts/health-check.sh --verbose

# Specific component checks
./scripts/health-check.sh --no-security
./scripts/health-check.sh --no-services
```

Configuration Validation

```bash
# Comprehensive config check
python tools/config-validator.py --env production

# Environment verification
python -c "import os; [print(f'{k}: {v}') for k, v in os.environ.items() if 'BLUX' in k]"
```

Audit Analysis

```bash
# Recent activity
python tools/audit-analyzer.py --last 1h

# Security-focused analysis
python tools/audit-analyzer.py --type security

# Performance analysis
python tools/audit-analyzer.py --type performance
```

External Tools

Network Debugging

```bash
# Check connectivity
nc -zv localhost 50050
telnet localhost 50051

# Network tracing
tcpdump -i any port 50050
```

Process Monitoring

```bash
# Real-time process monitoring
htop
iotop

# Open files
lsof -p $(pgrep blux-lite)

# System calls
strace -p $(pgrep blux-lite)
```

Common Debugging Scenarios

Scenario 1: Service Startup Failure

Symptoms: Service crashes immediately on startup

Debugging Steps:

1. Check basic requirements:

```bash
# Verify dependencies
python --version
docker --version
node --version  # if applicable

# Check file permissions
ls -la scripts/
ls -la ~/.config/blux/
```

1. Examine startup logs:

```bash
# Run with debug logging
BLUX_LOG_LEVEL=debug ./scripts/bootstrap.sh

# Check system logs
journalctl -u blux-lite -f  # systemd
docker-compose logs --tail=100 blux-lite
```

1. Test configuration:

```bash
# Validate configuration
python tools/config-validator.py

# Test environment setup
python -c "
import os
required_vars = ['BLUX_ENV', 'BLUX_AUDIT_PATH']
for var in required_vars:
    print(f'{var}: {os.getenv(var, \"MISSING\")}')
"
```

Scenario 2: Inter-Service Communication Issues

Symptoms: "Connection refused", "Service unavailable" errors

Debugging Steps:

1. Verify service discovery:

```bash
# Check if services are registered
curl -s http://localhost:50050/v1/services | jq .

# Test endpoint connectivity
for port in 50050 50051 50052 50053; do
    echo "Port $port: $(nc -zv localhost $port 2>&1 | grep succeeded)"
done
```

1. Check service health:

```bash
# Individual service health
services=("blux-reg" "blux-lite" "blux-guard" "blux-ca")
for service in "${services[@]}"; do
    echo "$service: $(curl -s http://localhost:50050/health | jq -r '.status')"
done
```

1. Network debugging:

```bash
# Check DNS resolution
nslookup blux-reg
dig +short blux-guard

# Check firewall rules
iptables -L -n | grep 5005
```

Scenario 3: Performance Degradation

Symptoms: Slow response times, high resource usage

Debugging Steps:

1. Identify bottlenecks:

```bash
# Resource monitoring
docker stats --no-stream
kubectl top pods -n blux

# Process analysis
ps aux --sort=-%cpu | head -10
ps aux --sort=-%mem | head -10
```

1. Database performance:

```sql
-- Check slow queries
SELECT query, calls, total_time, mean_time
FROM pg_stat_statements 
ORDER BY mean_time DESC 
LIMIT 10;

-- Check table sizes
SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename))
FROM pg_tables 
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

1. Application profiling:

```python
# Add performance logging
import time
from functools import wraps

def timer(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        start = time.perf_counter()
        result = func(*args, **kwargs)
        end = time.perf_counter()
        print(f"{func.__name__} took {end - start:.4f} seconds")
        return result
    return wrapper

@timer
def slow_operation():
    # Your code here
    pass
```

Scenario 4: Audit Trail Issues

Symptoms: Missing audit entries, audit write failures

Debugging Steps:

1. Verify audit configuration:

```bash
# Check audit path
echo $BLUX_AUDIT_PATH
ls -la $BLUX_AUDIT_PATH

# Test write permissions
touch $BLUX_AUDIT_PATH/test.txt && rm $BLUX_AUDIT_PATH/test.txt

# Check disk space
df -h $BLUX_AUDIT_PATH
```

1. Analyze audit content:

```bash
# Check recent audit entries
tail -n 100 $BLUX_AUDIT_PATH/*.jsonl | jq -s '.[-10:]'

# Look for errors in audit
grep -r "ERROR" $BLUX_AUDIT_PATH/ || echo "No errors found"

# Validate audit format
python -m json.tool $BLUX_AUDIT_PATH/latest.jsonl > /dev/null && echo "Valid JSON"
```

1. Audit performance:

```bash
# Monitor audit write performance
time curl -X POST http://localhost:50051/v1/tasks \
  -H "Content-Type: application/json" \
  -d '{"type": "test"}'

# Check audit file sizes
ls -lh $BLUX_AUDIT_PATH/*.jsonl
```

Advanced Debugging Techniques

Distributed Tracing

```python
# Implement distributed tracing
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider

tracer_provider = TracerProvider()
trace.set_tracer_provider(tracer_provider)

def process_task(task_id):
    tracer = trace.get_tracer(__name__)
    with tracer.start_as_current_span("process_task") as span:
        span.set_attribute("task.id", task_id)
        # Task processing logic
        span.add_event("task_processing_complete")
```

Memory Debugging

```python
# Track memory usage
import tracemalloc

def debug_memory():
    tracemalloc.start()
    
    # Your code here
    
    snapshot = tracemalloc.take_snapshot()
    top_stats = snapshot.statistics('lineno')
    
    print("[ Top 10 memory usage ]")
    for stat in top_stats[:10]:
        print(stat)
    
    tracemalloc.stop()
```

Async/Await Debugging

```python
# Debug asynchronous code
import asyncio
import logging

logging.basicConfig(level=logging.DEBUG)

async def debug_async_operation():
    try:
        result = await some_async_call()
        return result
    except Exception as e:
        logging.error(f"Async operation failed: {e}")
        # Add breakpoint for async debugging
        import pdb; pdb.set_trace()

# Run with debug event loop
asyncio.run(debug_async_operation(), debug=True)
```

Debugging in Production

Safe Production Debugging

1. Add debug endpoints (behind authentication):

```python
@app.get("/debug/memory")
async def debug_memory(auth: Auth = Depends(require_auth)):
    import gc
    gc.collect()
    return {
        "memory_usage": psutil.Process().memory_info().rss,
        "objects": len(gc.get_objects())
    }
```

1. Structured logging:

```python
import structlog

logger = structlog.get_logger()

def business_operation(user_id, data):
    logger.info("operation_started", user_id=user_id, data_size=len(data))
    try:
        result = process_data(data)
        logger.info("operation_completed", user_id=user_id, result_size=len(result))
        return result
    except Exception as e:
        logger.error("operation_failed", user_id=user_id, error=str(e))
        raise
```

1. Metrics and monitoring:

```python
from prometheus_client import Counter, Histogram

requests_total = Counter('blux_requests_total', 'Total requests', ['endpoint', 'status'])
request_duration = Histogram('blux_request_duration_seconds', 'Request duration')

@request_duration.time()
def handle_request(request):
    requests_total.labels(endpoint=request.path, status='200').inc()
    # Request handling logic
```

Debugging Workflow

Systematic Approach

1. Observe: Gather information without assumptions
2. Hypothesize: Form theories about root cause
3. Experiment: Test hypotheses systematically
4. Verify: Confirm the solution works
5. Document: Record findings for future reference

Debugging Checklist

· Reproduce the issue consistently
· Check recent changes (git log --oneline -10)
· Verify environment and configuration
· Examine logs and error messages
· Isolate the problem component
· Test potential fixes in isolation
· Verify the solution doesn't break other functionality
· Document the root cause and solution

Tools and Resources

Built-in Debug Scripts

· ./scripts/health-check.sh - System health verification
· ./scripts/anchor-list.sh - Development anchor discovery
· python tools/audit-analyzer.py - Audit trail analysis
· python tools/config-validator.py - Configuration validation

External Tools

· pdb/ipdb - Python debugger
· py-spy - Python profiler
· jq - JSON processor
· htop - Process monitor
· tcpdump - Network analysis

Documentation

· Architecture Guide - System design
· Integration Guide - Service interactions
· Common Issues - Known problems and solutions

---

Debugging is the art of finding truth in complexity.  (( • ))

Remember: The best debugger is a well-rested mind. Take breaks, step away, and return with fresh perspective.

---
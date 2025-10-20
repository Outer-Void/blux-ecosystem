# BLUX API Gateway

## Overview

The BLUX Ecosystem provides unified API access through a gateway pattern, offering consistent authentication, rate limiting, and observability across all services.

## Base URLs

| Environment | Base URL | Description |
|-------------|----------|-------------|
| Development | `http://localhost:8080` | Local development |
| Staging | `https://staging.api.blux.example` | Pre-production testing |
| Production | `https://api.blux.example` | Production services |

## Authentication

### Service-to-Service (mTLS)
```bash
# Using client certificates
curl --cert client.crt --key client.key \
  https://api.blux.example/v1/tasks
```

JWT Tokens

```bash
# Using bearer tokens
curl -H "Authorization: Bearer $BLUX_TOKEN" \
  https://api.blux.example/v1/tasks
```

Token Acquisition

```http
POST /v1/auth/token
Content-Type: application/json

{
  "grant_type": "client_credentials",
  "client_id": "service-name",
  "client_secret": "***"
}
```

Response:

```json
{
  "access_token": "eyJ...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "scope": "tasks:read tasks:write"
}
```

Core APIs

Tasks API

Create Task

```http
POST /v1/tasks
Content-Type: application/json
Authorization: Bearer $TOKEN

{
  "type": "data_analysis",
  "context": {
    "user_id": "user123",
    "environment": "production"
  },
  "payload": {
    "operation": "analyze",
    "data_references": ["ref://dataset/1"]
  }
}
```

Response:

```json
{
  "task_id": "task_abc123",
  "status": "accepted",
  "audit_id": "aud_xyz789",
  "estimated_completion": "2025-10-20T11:00:00Z"
}
```

Get Task Status

```http
GET /v1/tasks/{task_id}
Authorization: Bearer $TOKEN
```

Response:

```json
{
  "task_id": "task_abc123",
  "status": "completed",
  "result": {
    "analysis_complete": true,
    "insights_count": 42
  },
  "audit_trail": ["aud_xyz789", "aud_abc456"]
}
```

Audit API

Query Audit Trail

```http
GET /v1/audit?service=blux-lite&operation=task.execute&since=2025-10-20T00:00:00Z
Authorization: Bearer $TOKEN
```

Response:

```json
{
  "entries": [
    {
      "audit_id": "aud_xyz789",
      "timestamp": "2025-10-20T10:30:00Z",
      "service": "blux-lite",
      "operation": "task.execute",
      "identity": "user:alice",
      "signature": "es512-..."
    }
  ],
  "next_page_token": "abc123"
}
```

Identity API

Validate Identity

```http
POST /v1/identities/validate
Content-Type: application/json

{
  "token": "eyJ...",
  "required_scope": ["tasks:read"]
}
```

Response:

```json
{
  "valid": true,
  "identity": "user:alice",
  "scopes": ["tasks:read", "tasks:write"],
  "expires_at": "2025-10-20T11:30:00Z"
}
```

Event Streaming

WebSocket Connection

```javascript
const ws = new WebSocket('wss://api.blux.example/v1/events');

ws.onmessage = (event) => {
  const message = JSON.parse(event.data);
  console.log('Event received:', message);
};

// Subscribe to events
ws.send(JSON.stringify({
  type: 'subscribe',
  channels: ['task_updates', 'audit_events']
}));
```

Server-Sent Events

```http
GET /v1/events
Accept: text/event-stream
Authorization: Bearer $TOKEN
```

Rate Limiting

· Per service: 1000 requests/minute
· Per user: 100 requests/minute
· Burst capacity: 50 requests/second

Headers included in responses:

```http
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1600000000
```

Error Handling

Standard Error Response

```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Rate limit exceeded",
    "details": {
      "limit": 1000,
      "reset_in": 60
    },
    "audit_id": "aud_err_123",
    "timestamp": "2025-10-20T10:30:00Z"
  }
}
```

Common Error Codes

Code HTTP Status Description
UNAUTHORIZED 401 Authentication required
FORBIDDEN 403 Insufficient permissions
RATE_LIMIT_EXCEEDED 429 Too many requests
VALIDATION_FAILED 400 Request validation failed
SERVICE_UNAVAILABLE 503 Backend service unavailable

SDKs

Python

```python
from blux_sdk import BLUXClient

client = BLUXClient(
    base_url="https://api.blux.example",
    token=os.getenv('BLUX_TOKEN')
)

task = client.tasks.create(
    type="data_analysis",
    context={"user_id": "alice"}
)
```

JavaScript

```javascript
import { BLUXClient } from '@blux/sdk';

const client = new BLUXClient({
  baseURL: 'https://api.blux.example',
  token: process.env.BLUX_TOKEN
});

const task = await client.tasks.create({
  type: 'data_analysis',
  context: { userId: 'alice' }
});
```

Testing

Mock Server

```python
from blux_sdk.testing import MockBLUXServer

with MockBLUXServer() as server:
    client = BLUXClient(base_url=server.url)
    # Test with mock responses
```

Integration Testing

```bash
# Use test token
export BLUX_TOKEN=test_token_123

# Run against test environment
pytest tests/integration/
```

Monitoring

Health Check

```http
GET /health
```

Response:

```json
{
  "status": "healthy",
  "services": {
    "blux-lite": "healthy",
    "blux-guard": "healthy",
    "blux-reg": "healthy"
  },
  "timestamp": "2025-10-20T10:30:00Z"
}
```

Metrics

```http
GET /metrics
```

Prometheus format metrics for monitoring.

---

Clear APIs enable clear coordination.  (( • ))

---
# Basic Integration Examples

## Overview

Practical examples showing how to integrate with BLUX Ecosystem services for common use cases.

## Quick Start Example

### Basic Service Integration
```python
#!/usr/bin/env python3
"""
Basic BLUX Integration Example
Demonstrates simple service integration patterns.
"""

import asyncio
import aiohttp
import json
from typing import Dict, Any

class BLUXClient:
    """Basic BLUX client for service integration."""
    
    def __init__(self, base_url: str = "http://localhost:8080"):
        self.base_url = base_url.rstrip('/')
        self.session = None
        
    async def __aenter__(self):
        self.session = aiohttp.ClientSession()
        return self
        
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        if self.session:
            await self.session.close()
    
    async def health_check(self) -> Dict[str, Any]:
        """Check service health."""
        async with self.session.get(f"{self.base_url}/health") as response:
            return await response.json()
    
    async def create_task(self, task_type: str, context: Dict) -> Dict[str, Any]:
        """Create a new task."""
        payload = {
            "type": task_type,
            "context": context,
            "doctrine_requirements": {
                "require_reflection": True,
                "sandbox_execution": True
            }
        }
        
        async with self.session.post(
            f"{self.base_url}/v1/tasks",
            json=payload,
            headers={"Content-Type": "application/json"}
        ) as response:
            return await response.json()
    
    async def get_task_status(self, task_id: str) -> Dict[str, Any]:
        """Get task status by ID."""
        async with self.session.get(f"{self.base_url}/v1/tasks/{task_id}") as response:
            return await response.json()

# Example usage
async def main():
    """Demonstrate basic BLUX integration."""
    async with BLUXClient() as client:
        # Check service health
        health = await client.health_check()
        print(f"Service health: {health['status']}")
        
        # Create a sample task
        task = await client.create_task(
            task_type="data_analysis",
            context={
                "user_id": "example_user",
                "environment": "development",
                "data_source": "sample_dataset"
            }
        )
        
        print(f"Created task: {task['task_id']}")
        print(f"Audit ID: {task['audit_id']}")
        
        # Check task status
        status = await client.get_task_status(task['task_id'])
        print(f"Task status: {status['status']}")

if __name__ == "__main__":
    asyncio.run(main())
```

Authentication Examples

JWT Token Authentication

```python
import jwt
import time
from datetime import datetime, timedelta

class BLUXAuthenticator:
    """Handles BLUX authentication."""
    
    def __init__(self, private_key_path: str, service_name: str):
        self.private_key_path = private_key_path
        self.service_name = service_name
        
    def load_private_key(self) -> str:
        """Load private key from file."""
        with open(self.private_key_path, 'r') as f:
            return f.read().strip()
    
    def generate_token(self, expires_in: int = 3600) -> str:
        """Generate JWT token for service authentication."""
        private_key = self.load_private_key()
        
        payload = {
            'iss': self.service_name,
            'sub': self.service_name,
            'aud': 'blux-ecosystem',
            'exp': datetime.utcnow() + timedelta(seconds=expires_in),
            'iat': datetime.utcnow(),
            'scope': ['tasks:read', 'tasks:write', 'audit:read']
        }
        
        return jwt.encode(payload, private_key, algorithm='ES512')

# Usage
authenticator = BLUXAuthenticator(
    private_key_path='keys/service.key',
    service_name='my-integration-service'
)

token = authenticator.generate_token()
print(f"Authentication token: {token}")
```

mTLS Authentication

```python
import ssl
import aiohttp

class SecureBLUXClient:
    """Client with mTLS authentication."""
    
    def __init__(self, cert_file: str, key_file: str, ca_bundle: str):
        self.cert_file = cert_file
        self.key_file = key_file
        self.ca_bundle = ca_bundle
        
    def create_ssl_context(self) -> ssl.SSLContext:
        """Create SSL context for mTLS."""
        ssl_context = ssl.create_default_context(
            cafile=self.ca_bundle,
            purpose=ssl.Purpose.SERVER_AUTH
        )
        ssl_context.load_cert_chain(self.cert_file, self.key_file)
        ssl_context.check_hostname = False  # For development
        return ssl_context
    
    async def make_secure_request(self, url: str) -> Dict[str, Any]:
        """Make secure request with mTLS."""
        ssl_context = self.create_ssl_context()
        
        connector = aiohttp.TCPConnector(ssl=ssl_context)
        async with aiohttp.ClientSession(connector=connector) as session:
            async with session.get(url) as response:
                return await response.json()

# Usage
client = SecureBLUXClient(
    cert_file='certs/client.crt',
    key_file='certs/client.key', 
    ca_bundle='certs/ca.crt'
)

# response = await client.make_secure_request('https://blux-lite:443/health')
```

Task Processing Examples

Simple Task Orchestration

```python
import asyncio
from enum import Enum
from typing import List, Optional

class TaskStatus(Enum):
    PENDING = "pending"
    RUNNING = "running" 
    COMPLETED = "completed"
    FAILED = "failed"

class TaskOrchestrator:
    """Orchestrates task processing through BLUX."""
    
    def __init__(self, blux_client: BLUXClient):
        self.client = blux_client
        self.pending_tasks = asyncio.Queue()
        self.completed_tasks = asyncio.Queue()
        
    async def submit_task(self, task_type: str, payload: Dict) -> str:
        """Submit a task for processing."""
        task_response = await self.client.create_task(task_type, payload)
        task_id = task_response['task_id']
        
        await self.pending_tasks.put({
            'task_id': task_id,
            'type': task_type,
            'submitted_at': asyncio.get_event_loop().time()
        })
        
        return task_id
    
    async def process_tasks(self, batch_size: int = 10):
        """Process tasks in batches."""
        while True:
            # Wait for tasks or timeout
            try:
                tasks = [await asyncio.wait_for(
                    self.pending_tasks.get(), 
                    timeout=1.0
                )]
                
                # Get more tasks if available
                for _ in range(batch_size - 1):
                    try:
                        task = self.pending_tasks.get_nowait()
                        tasks.append(task)
                    except asyncio.QueueEmpty:
                        break
                        
                # Process batch
                await self._process_batch(tasks)
                
            except asyncio.TimeoutError:
                # No tasks, continue
                continue
    
    async def _process_batch(self, tasks: List[Dict]):
        """Process a batch of tasks."""
        processing_tasks = []
        
        for task_info in tasks:
            task = asyncio.create_task(
                self._process_single_task(task_info)
            )
            processing_tasks.append(task)
        
        # Wait for all tasks to complete
        await asyncio.gather(*processing_tasks)
    
    async def _process_single_task(self, task_info: Dict):
        """Process a single task."""
        task_id = task_info['task_id']
        
        try:
            # Monitor task status
            status = await self._monitor_task_status(task_id)
            
            if status == TaskStatus.COMPLETED:
                result = await self.client.get_task_status(task_id)
                await self.completed_tasks.put({
                    'task_id': task_id,
                    'result': result,
                    'completed_at': asyncio.get_event_loop().time()
                })
                
        except Exception as e:
            print(f"Task {task_id} failed: {e}")
    
    async def _monitor_task_status(self, task_id: str) -> TaskStatus:
        """Monitor task status until completion."""
        while True:
            status_info = await self.client.get_task_status(task_id)
            status = TaskStatus(status_info['status'])
            
            if status in [TaskStatus.COMPLETED, TaskStatus.FAILED]:
                return status
                
            # Wait before checking again
            await asyncio.sleep(1.0)

# Usage example
async def orchestration_example():
    """Demonstrate task orchestration."""
    async with BLUXClient() as client:
        orchestrator = TaskOrchestrator(client)
        
        # Start task processor
        processor_task = asyncio.create_task(
            orchestrator.process_tasks()
        )
        
        # Submit some tasks
        tasks = []
        for i in range(5):
            task_id = await orchestrator.submit_task(
                task_type="data_processing",
                payload={"dataset": f"dataset_{i}", "operation": "analyze"}
            )
            tasks.append(task_id)
            print(f"Submitted task: {task_id}")
        
        # Wait for processing
        await asyncio.sleep(10)
        
        # Check completed tasks
        completed_count = orchestrator.completed_tasks.qsize()
        print(f"Completed tasks: {completed_count}")
        
        # Cleanup
        processor_task.cancel()
        try:
            await processor_task
        except asyncio.CancelledError:
            pass

# Run example
# asyncio.run(orchestration_example())
```

Audit Integration Examples

Audit Trail Monitoring

```python
import time
from datetime import datetime, timedelta

class AuditMonitor:
    """Monitors and analyzes audit trails."""
    
    def __init__(self, blux_client: BLUXClient):
        self.client = blux_client
        self.last_check = datetime.utcnow()
        
    async def monitor_audit_events(self, callback):
        """
        Monitor audit events and call callback for new events.
        
        Args:
            callback: Async function that receives audit events
        """
        while True:
            try:
                # Get events since last check
                events = await self._get_recent_events()
                
                for event in events:
                    await callback(event)
                
                self.last_check = datetime.utcnow()
                await asyncio.sleep(5.0)  # Check every 5 seconds
                
            except Exception as e:
                print(f"Audit monitoring error: {e}")
                await asyncio.sleep(10.0)  # Backoff on error
    
    async def _get_recent_events(self) -> List[Dict]:
        """Get events since last check."""
        # This would call the audit API
        # For now, return mock data
        return [
            {
                "audit_id": f"aud_{int(time.time())}",
                "timestamp": datetime.utcnow().isoformat(),
                "service": "blux-lite",
                "operation": "task.execute",
                "identity": "user:example",
                "data": {"task_id": "task_123"}
            }
        ]
    
    async def analyze_audit_patterns(self, hours: int = 24):
        """Analyze audit patterns over time."""
        end_time = datetime.utcnow()
        start_time = end_time - timedelta(hours=hours)
        
        # This would query the audit API for the time range
        print(f"Analyzing audit patterns from {start_time} to {end_time}")
        
        # Mock analysis results
        return {
            "total_events": 1500,
            "services": {
                "blux-lite": 800,
                "blux-guard": 400,
                "blux-reg": 300
            },
            "operations": {
                "task.execute": 600,
                "auth.verify": 400,
                "audit.write": 500
            }
        }

# Usage example
async def handle_audit_event(event: Dict):
    """Handle incoming audit events."""
    print(f"Audit event: {event['operation']} by {event['service']}")
    
    # Example: Alert on security events
    if event['operation'] in ['auth.failed', 'access.denied']:
        print(f"SECURITY ALERT: {event}")

async def audit_monitoring_example():
    """Demonstrate audit monitoring."""
    async with BLUXClient() as client:
        monitor = AuditMonitor(client)
        
        # Start monitoring
        monitor_task = asyncio.create_task(
            monitor.monitor_audit_events(handle_audit_event)
        )
        
        # Run analysis
        analysis = await monitor.analyze_audit_patterns(hours=1)
        print(f"Audit analysis: {analysis}")
        
        # Let it run for a bit
        await asyncio.sleep(30)
        
        # Stop monitoring
        monitor_task.cancel()
        try:
            await monitor_task
        except asyncio.CancelledError:
            print("Audit monitoring stopped")

# Run example  
# asyncio.run(audit_monitoring_example())
```

Error Handling Examples

Robust Service Integration

```python
from typing import TypeVar, Callable
import asyncio
import random

T = TypeVar('T')

class ResilientBLUXClient:
    """BLUX client with built-in resilience patterns."""
    
    def __init__(self, base_url: str, max_retries: int = 3):
        self.base_url = base_url
        self.max_retries = max_retries
        
    async def with_retry(self, operation: Callable[..., T], *args, **kwargs) -> T:
        """
        Execute operation with retry logic.
        
        Args:
            operation: Async function to execute
            *args: Positional arguments for operation
            **kwargs: Keyword arguments for operation
            
        Returns:
            Operation result
            
        Raises:
            Exception: If all retries fail
        """
        last_exception = None
        
        for attempt in range(self.max_retries):
            try:
                return await operation(*args, **kwargs)
                
            except asyncio.TimeoutError as e:
                last_exception = e
                print(f"Attempt {attempt + 1} failed: Timeout")
                
            except aiohttp.ClientError as e:
                last_exception = e
                print(f"Attempt {attempt + 1} failed: Client error - {e}")
                
            except Exception as e:
                last_exception = e
                print(f"Attempt {attempt + 1} failed: {e}")
            
            # Exponential backoff with jitter
            if attempt < self.max_retries - 1:
                delay = (2 ** attempt) + random.uniform(0, 1)
                print(f"Retrying in {delay:.2f} seconds...")
                await asyncio.sleep(delay)
        
        # All retries failed
        raise last_exception
    
    async def create_task_with_retry(self, task_type: str, context: Dict) -> Dict:
        """Create task with retry logic."""
        async with aiohttp.ClientSession() as session:
            operation = lambda: self._create_task_impl(session, task_type, context)
            return await self.with_retry(operation)
    
    async def _create_task_impl(self, session: aiohttp.ClientSession, 
                              task_type: str, context: Dict) -> Dict:
        """Actual task creation implementation."""
        payload = {
            "type": task_type,
            "context": context
        }
        
        async with session.post(
            f"{self.base_url}/v1/tasks",
            json=payload,
            timeout=aiohttp.ClientTimeout(total=30)
        ) as response:
            if response.status >= 400:
                raise aiohttp.ClientError(f"HTTP {response.status}")
            return await response.json()

# Usage example
async def resilient_example():
    """Demonstrate resilient service integration."""
    client = ResilientBLUXClient("http://localhost:8080")
    
    try:
        task = await client.create_task_with_retry(
            task_type="important_processing",
            context={"critical": True, "data": "important_data"}
        )
        print(f"Successfully created task: {task['task_id']}")
        
    except Exception as e:
        print(f"Failed to create task after retries: {e}")

# Run example
# asyncio.run(resilient_example())
```

Configuration Examples

Dynamic Configuration Management

```python
import yaml
from typing import Dict, Any

class BLUXConfigManager:
    """Manages BLUX service configuration."""
    
    def __init__(self, config_path: str = "config/blux-config.yaml"):
        self.config_path = config_path
        self.config = self._load_config()
    
    def _load_config(self) -> Dict[str, Any]:
        """Load configuration from file."""
        try:
            with open(self.config_path, 'r') as f:
                return yaml.safe_load(f)
        except FileNotFoundError:
            return self._default_config()
    
    def _default_config(self) -> Dict[str, Any]:
        """Return default configuration."""
        return {
            'environment': 'development',
            'services': {
                'blux_lite': {
                    'host': 'localhost',
                    'port': 50051,
                    'timeout': 30
                },
                'blux_guard': {
                    'host': 'localhost',
                    'port': 50052,
                    'timeout': 30
                }
            },
            'security': {
                'require_authentication': False,
                'audit_all_operations': True
            }
        }
    
    def get_service_config(self, service_name: str) -> Dict[str, Any]:
        """Get configuration for a specific service."""
        return self.config['services'].get(service_name, {})
    
    def update_config(self, updates: Dict[str, Any]):
        """Update configuration dynamically."""
        # Deep merge updates
        self._deep_update(self.config, updates)
        
        # Save to file
        self._save_config()
    
    def _deep_update(self, original: Dict, updates: Dict):
        """Deep update a dictionary."""
        for key, value in updates.items():
            if (key in original and isinstance(original[key], dict) 
                and isinstance(value, dict)):
                self._deep_update(original[key], value)
            else:
                original[key] = value
    
    def _save_config(self):
        """Save configuration to file."""
        with open(self.config_path, 'w') as f:
            yaml.dump(self.config, f, default_flow_style=False)

# Usage example
def config_example():
    """Demonstrate configuration management."""
    config_mgr = BLUXConfigManager()
    
    # Get service configuration
    lite_config = config_mgr.get_service_config('blux_lite')
    print(f"BLUX Lite config: {lite_config}")
    
    # Update configuration
    config_mgr.update_config({
        'services': {
            'blux_lite': {
                'timeout': 60  # Increase timeout
            }
        }
    })
    
    print("Configuration updated")

# Run example
# config_example()
```

Testing Examples

Integration Testing

```python
import pytest
import asyncio
from unittest.mock import AsyncMock, patch

class TestBLUXIntegration:
    """Integration tests for BLUX services."""
    
    @pytest.fixture
    async def blux_client(self):
        """Create BLUX client for testing."""
        async with BLUXClient("http://localhost:8080") as client:
            yield client
    
    @pytest.mark.asyncio
    async def test_health_check(self, blux_client):
        """Test service health check."""
        health = await blux_client.health_check()
        assert health['status'] == 'healthy'
        assert 'services' in health
    
    @pytest.mark.asyncio 
    async def test_task_creation(self, blux_client):
        """Test task creation and status checking."""
        # Create task
        task = await blux_client.create_task(
            task_type="test_operation",
            context={"test": True}
        )
        
        assert 'task_id' in task
        assert 'audit_id' in task
        
        # Check status
        status = await blux_client.get_task_status(task['task_id'])
        assert 'status' in status
        assert status['task_id'] == task['task_id']
    
    @pytest.mark.asyncio
    async def test_error_handling(self, blux_client):
        """Test error handling for invalid requests."""
        with pytest.raises(Exception):  # Should be more specific
            await blux_client.create_task("", {})  # Invalid task type

# Mock testing example
@pytest.mark.asyncio
async def test_with_mocks():
    """Test with mocked BLUX services."""
    with patch('aiohttp.ClientSession') as mock_session:
        mock_response = AsyncMock()
        mock_response.json.return_value = {
            'status': 'healthy',
            'services': {'blux-lite': 'healthy'}
        }
        mock_session.get.return_value.__aenter__.return_value = mock_response
        
        async with BLUXClient() as client:
            health = await client.health_check()
            assert health['status'] == 'healthy'
```

Deployment Examples

Docker Compose Integration

```yaml
# docker-compose.integration.yml
version: '3.8'

services:
  my-integration-app:
    build: .
    environment:
      - BLUX_ENV=production
      - BLUX_LITE_HOST=blux-lite
      - BLUX_GUARD_HOST=blux-guard
      - BLUX_REG_HOST=blux-reg
    depends_on:
      - blux-lite
      - blux-guard
      - blux-reg
    
  blux-lite:
    image: blux/lite:latest
    environment:
      - BLUX_ENV=production
    ports:
      - "50051:8080"
    
  blux-guard:
    image: blux/guard:latest  
    environment:
      - BLUX_ENV=production
    ports:
      - "50052:8080"
      
  blux-reg:
    image: blux/reg:latest
    environment:
      - BLUX_ENV=production
    ports:
      - "50050:8080"

networks:
  default:
    name: blux-integration
```

---

Examples illuminate the path from concept to implementation.  (( • ))

Next Steps:

· Explore the API Gateway for detailed API documentation
· Check Common Issues for troubleshooting
· Review the Architecture Guide for system design understanding

---
# Custom Module Development Guide

## Overview

Learn how to create custom modules that integrate with the BLUX Ecosystem while following BLUX principles and patterns.

## Module Template

### Basic Structure
```

my-blux-module/
├──README.md
├──pyproject.toml              # Python project config
├──Dockerfile
├──.dockerignore
├──.gitignore
├──manifests/
│├── module.manifest.json
│└── doctrine.policy.json
├──src/
│└── my_blux_module/
│├── init.py
│├── core.py
│├── api.py
│├── models.py
│└── config.py
├──tests/
│├── init.py
│├── test_core.py
│├── test_api.py
│└── conftest.py
├──scripts/
│├── bootstrap.sh
│├── health-check.sh
│└── deploy.sh
└──docs/
├── integration.md
└── api.md

```

### Module Manifest
```json
{
  "module": {
    "name": "my-blux-module",
    "version": "1.0.0",
    "description": "Custom BLUX module for specialized processing",
    "type": "processor",
    "capabilities": ["data_transformation", "custom_analysis"],
    "requirements": {
      "blux-lite": ">=1.0.0",
      "blux-guard": ">=1.0.0"
    }
  },
  "integration": {
    "events": {
      "consumes": ["task.assigned", "data.available"],
      "produces": ["task.completed", "analysis.ready"]
    },
    "apis": {
      "provided": ["/v1/analyze", "/v1/transform"],
      "required": ["/v1/tasks", "/v1/audit"]
    }
  },
  "security": {
    "authentication": "required",
    "audit_level": "detailed",
    "data_handling": "encrypted"
  }
}
```

Core Module Implementation

Basic Module Class

```python
"""
ANCHOR: module_core
"""
import asyncio
import logging
from typing import Dict, Any, Optional
from dataclasses import dataclass
from enum import Enum

class ModuleStatus(Enum):
    INITIALIZING = "initializing"
    READY = "ready"
    PROCESSING = "processing"
    ERROR = "error"

@dataclass
class ModuleConfig:
    """Module configuration."""
    name: str
    version: str
    blux_lite_host: str = "localhost:50051"
    blux_guard_host: str = "localhost:50052"
    max_concurrent_tasks: int = 10
    enable_audit: bool = True

class BLUXModule:
    """
    Base class for BLUX modules.
    Provides common functionality and integration patterns.
    """
    
    def __init__(self, config: ModuleConfig):
        self.config = config
        self.status = ModuleStatus.INITIALIZING
        self.logger = logging.getLogger(self.config.name)
        self.task_queue = asyncio.Queue()
        self.active_tasks: Dict[str, asyncio.Task] = {}
        
    async def initialize(self) -> None:
        """Initialize the module."""
        self.logger.info(f"Initializing {self.config.name} v{self.config.version}")
        
        # Register with BLUX ecosystem
        await self._register_module()
        
        # Start task processor
        asyncio.create_task(self._process_tasks())
        
        self.status = ModuleStatus.READY
        self.logger.info("Module initialized and ready")
    
    async def _register_module(self) -> None:
        """Register module with BLUX ecosystem."""
        # This would typically call blux-lite registration endpoint
        registration_data = {
            "module": self.config.name,
            "version": self.config.version,
            "capabilities": self.get_capabilities(),
            "endpoints": self.get_endpoints()
        }
        
        self.logger.debug(f"Registering module: {registration_data}")
        # Implementation would go here
    
    def get_capabilities(self) -> Dict[str, Any]:
        """Return module capabilities."""
        return {
            "data_processing": True,
            "custom_analysis": True,
            "audit_integration": self.config.enable_audit
        }
    
    def get_endpoints(self) -> Dict[str, str]:
        """Return module API endpoints."""
        return {
            "health": "/health",
            "process": "/v1/process",
            "status": "/v1/status"
        }
    
    async def process_task(self, task_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Process a task - to be implemented by specific modules.
        
        Args:
            task_data: Task data from BLUX Lite
            
        Returns:
            Processing results
        """
        raise NotImplementedError("Subclasses must implement process_task")
    
    async def _process_tasks(self) -> None:
        """Background task processing loop."""
        while True:
            try:
                task_id, task_data = await self.task_queue.get()
                
                # Limit concurrent tasks
                if len(self.active_tasks) >= self.config.max_concurrent_tasks:
                    await asyncio.sleep(0.1)
                    self.task_queue.put_nowait((task_id, task_data))
                    continue
                
                # Process task
                task = asyncio.create_task(
                    self._process_single_task(task_id, task_data)
                )
                self.active_tasks[task_id] = task
                
            except Exception as e:
                self.logger.error(f"Task processing error: {e}")
    
    async def _process_single_task(self, task_id: str, task_data: Dict[str, Any]) -> None:
        """Process a single task with error handling."""
        try:
            self.logger.info(f"Processing task {task_id}")
            
            # Record audit entry
            audit_id = await self._record_audit("task.start", {"task_id": task_id})
            
            # Process the task
            result = await self.process_task(task_data)
            
            # Record completion
            await self._record_audit("task.complete", {
                "task_id": task_id,
                "audit_id": audit_id,
                "result": result
            })
            
            self.logger.info(f"Completed task {task_id}")
            
        except Exception as e:
            self.logger.error(f"Task {task_id} failed: {e}")
            await self._record_audit("task.error", {
                "task_id": task_id,
                "error": str(e)
            })
            
        finally:
            # Cleanup
            self.active_tasks.pop(task_id, None)
            self.task_queue.task_done()
    
    async def _record_audit(self, operation: str, data: Dict[str, Any]) -> str:
        """Record audit entry."""
        if not self.config.enable_audit:
            return "audit_disabled"
        
        # This would integrate with blux-guard audit system
        audit_entry = {
            "timestamp": asyncio.get_event_loop().time(),
            "module": self.config.name,
            "operation": operation,
            "data": data
        }
        
        self.logger.debug(f"Audit entry: {audit_entry}")
        return f"aud_{hash(str(audit_entry))}"
    
    async def health_check(self) -> Dict[str, Any]:
        """Return module health status."""
        return {
            "status": self.status.value,
            "module": self.config.name,
            "version": self.config.version,
            "active_tasks": len(self.active_tasks),
            "queue_size": self.task_queue.qsize()
        }
"""
ANCHOR_END: module_core
"""
```

Specialized Module Implementation

```python
"""
ANCHOR: specialized_module
"""
import json
from typing import Dict, Any, List
import pandas as pd  # Example dependency

class DataAnalysisModule(BLUXModule):
    """
    Specialized module for data analysis tasks.
    Extends the base BLUXModule with analysis capabilities.
    """
    
    def __init__(self, config: ModuleConfig):
        super().__init__(config)
        self.analysis_cache = {}
        
    def get_capabilities(self) -> Dict[str, Any]:
        """Return analysis-specific capabilities."""
        base_capabilities = super().get_capabilities()
        base_capabilities.update({
            "statistical_analysis": True,
            "pattern_detection": True,
            "data_visualization": False,  # Could be enabled in future
            "machine_learning": False
        })
        return base_capabilities
    
    async def process_task(self, task_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Process data analysis task.
        
        Expected task_data format:
        {
            "analysis_type": "statistical|pattern|trend",
            "data": {...} or "data_reference": "...",
            "parameters": {...}
        }
        """
        analysis_type = task_data.get("analysis_type", "statistical")
        
        # Extract data
        data = await self._extract_data(task_data)
        
        # Perform analysis based on type
        if analysis_type == "statistical":
            result = await self._statistical_analysis(data, task_data.get("parameters", {}))
        elif analysis_type == "pattern":
            result = await self._pattern_analysis(data, task_data.get("parameters", {}))
        elif analysis_type == "trend":
            result = await self._trend_analysis(data, task_data.get("parameters", {}))
        else:
            raise ValueError(f"Unknown analysis type: {analysis_type}")
        
        return {
            "analysis_type": analysis_type,
            "result": result,
            "metadata": {
                "data_points": len(data) if hasattr(data, '__len__') else 1,
                "processing_time": 0.1  # Would be actual timing
            }
        }
    
    async def _extract_data(self, task_data: Dict[str, Any]) -> Any:
        """Extract data from task data or reference."""
        if "data" in task_data:
            return task_data["data"]
        elif "data_reference" in task_data:
            # Would fetch from data service
            return await self._fetch_data(task_data["data_reference"])
        else:
            raise ValueError("No data or data_reference provided")
    
    async def _fetch_data(self, data_reference: str) -> Any:
        """Fetch data from reference (would integrate with data services)."""
        # Mock implementation
        return {"sample": "data", "values": [1, 2, 3, 4, 5]}
    
    async def _statistical_analysis(self, data: Any, parameters: Dict) -> Dict[str, Any]:
        """Perform statistical analysis."""
        if isinstance(data, dict) and 'values' in data:
            values = data['values']
            return {
                "mean": sum(values) / len(values),
                "std_dev": (sum((x - sum(values)/len(values))**2 for x in values) / len(values))**0.5,
                "min": min(values),
                "max": max(values),
                "count": len(values)
            }
        else:
            return {"error": "Unsupported data format for statistical analysis"}
    
    async def _pattern_analysis(self, data: Any, parameters: Dict) -> Dict[str, Any]:
        """Perform pattern analysis."""
        # Simplified pattern detection
        if isinstance(data, dict) and 'values' in data:
            values = data['values']
            patterns = []
            
            # Simple pattern: increasing sequence
            if all(values[i] < values[i+1] for i in range(len(values)-1)):
                patterns.append("increasing_sequence")
            
            # Simple pattern: decreasing sequence  
            if all(values[i] > values[i+1] for i in range(len(values)-1)):
                patterns.append("decreasing_sequence")
            
            return {"patterns_detected": patterns, "pattern_count": len(patterns)}
        else:
            return {"error": "Unsupported data format for pattern analysis"}
    
    async def _trend_analysis(self, data: Any, parameters: Dict) -> Dict[str, Any]:
        """Perform trend analysis."""
        if isinstance(data, dict) and 'values' in data:
            values = data['values']
            if len(values) >= 2:
                trend = "increasing" if values[-1] > values[0] else "decreasing"
                change_percentage = ((values[-1] - values[0]) / values[0]) * 100
                
                return {
                    "trend": trend,
                    "change_percentage": change_percentage,
                    "initial_value": values[0],
                    "final_value": values[-1]
                }
            else:
                return {"error": "Insufficient data for trend analysis"}
        else:
            return {"error": "Unsupported data format for trend analysis"}
"""
ANCHOR_END: specialized_module
"""
```

API Implementation

FastAPI Integration

```python
"""
ANCHOR: module_api
"""
from fastapi import FastAPI, HTTPException, Depends, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import List, Optional

# Pydantic models for API
class TaskRequest(BaseModel):
    analysis_type: str = Field(..., description="Type of analysis to perform")
    data: Optional[Dict[str, Any]] = Field(None, description="Direct data input")
    data_reference: Optional[str] = Field(None, description="Reference to external data")
    parameters: Dict[str, Any] = Field(default_factory=dict, description="Analysis parameters")

class TaskResponse(BaseModel):
    task_id: str = Field(..., description="Unique task identifier")
    status: str = Field(..., description="Task status")
    audit_id: str = Field(..., description="Audit trail identifier")

class HealthResponse(BaseModel):
    status: str = Field(..., description="Module status")
    module: str = Field(..., description="Module name")
    version: str = Field(..., description="Module version")
    active_tasks: int = Field(..., description="Number of active tasks")
    queue_size: int = Field(..., description="Tasks waiting in queue")

class AnalysisModuleAPI:
    """
    FastAPI wrapper for BLUX modules.
    Provides RESTful API for module interaction.
    """
    
    def __init__(self, module: BLUXModule, title: str = "BLUX Module API"):
        self.module = module
        self.app = FastAPI(title=title, version=module.config.version)
        
        # Configure CORS
        self.app.add_middleware(
            CORSMiddleware,
            allow_origins=["*"],  # Configure appropriately
            allow_credentials=True,
            allow_methods=["*"],
            allow_headers=["*"],
        )
        
        self._setup_routes()
    
    def _setup_routes(self) -> None:
        """Setup API routes."""
        
        @self.app.get("/health", response_model=HealthResponse)
        async def health_check():
            """Health check endpoint."""
            return await self.module.health_check()
        
        @self.app.post("/v1/analyze", response_model=TaskResponse)
        async def analyze_data(
            request: TaskRequest,
            background_tasks: BackgroundTasks
        ):
            """Submit data for analysis."""
            try:
                # Generate task ID
                task_id = f"task_{hash(str(request.dict()))}"
                
                # Submit for processing
                await self.module.task_queue.put((task_id, request.dict()))
                
                return TaskResponse(
                    task_id=task_id,
                    status="submitted",
                    audit_id=f"aud_{task_id}"
                )
                
            except Exception as e:
                raise HTTPException(status_code=500, detail=str(e))
        
        @self.app.get("/v1/tasks/{task_id}")
        async def get_task_status(task_id: str):
            """Get task status."""
            if task_id in self.module.active_tasks:
                return {"task_id": task_id, "status": "processing"}
            else:
                return {"task_id": task_id, "status": "completed"}  # Simplified
        
        @self.app.get("/capabilities")
        async def get_capabilities():
            """Get module capabilities."""
            return self.module.get_capabilities()

# Usage example
def create_api() -> FastAPI:
    """Create and configure the API instance."""
    config = ModuleConfig(
        name="data-analysis-module",
        version="1.0.0",
        max_concurrent_tasks=5
    )
    
    module = DataAnalysisModule(config)
    api = AnalysisModuleAPI(module)
    
    # Add startup event to initialize module
    @api.app.on_event("startup")
    async def startup_event():
        await module.initialize()
    
    return api.app

# For running directly
if __name__ == "__main__":
    import uvicorn
    
    app = create_api()
    uvicorn.run(app, host="0.0.0.0", port=8000)
"""
ANCHOR_END: module_api
```

```

## Configuration Management

### Module Configuration
```python
"""
ANCHOR: module_config
"""
import os
from typing import Dict, Any
import yaml
from pydantic import BaseSettings, validator

class ModuleSettings(BaseSettings):
    """Module settings with validation."""
    
    # Basic settings
    module_name: str = "my-blux-module"
    module_version: str = "1.0.0"
    environment: str = "development"
    
    # BLUX integration
    blux_lite_host: str = "localhost:50051"
    blux_guard_host: str = "localhost:50052"
    blux_reg_host: str = "localhost:50050"
    
    # Performance
    max_concurrent_tasks: int = 10
    task_timeout_seconds: int = 300
    
    # Security
    enable_authentication: bool = True
    audit_level: str = "detailed"
    
    # Custom settings
    analysis_cache_size: int = 1000
    enable_advanced_analytics: bool = False
    
    class Config:
        env_prefix = "BLUX_MODULE_"
        case_sensitive = False
    
    @validator('environment')
    def validate_environment(cls, v):
        allowed = ['development', 'staging', 'production']
        if v not in allowed:
            raise ValueError(f'Environment must be one of {allowed}')
        return v
    
    @validator('audit_level')
    def validate_audit_level(cls, v):
        allowed = ['none', 'basic', 'detailed', 'verbose']
        if v not in allowed:
            raise ValueError(f'Audit level must be one of {allowed}')
        return v

class ConfigManager:
    """Manages module configuration."""
    
    def __init__(self, config_path: str = None):
        self.config_path = config_path
        self.settings = ModuleSettings()
        self.custom_config: Dict[str, Any] = {}
        
    def load_from_file(self, file_path: str) -> None:
        """Load configuration from YAML file."""
        with open(file_path, 'r') as f:
            file_config = yaml.safe_load(f)
            self.custom_config.update(file_config)
    
    def get(self, key: str, default: Any = None) -> Any:
        """Get configuration value."""
        # Check environment variables first
        env_key = f"BLUX_MODULE_{key.upper()}"
        if env_key in os.environ:
            return os.environ[env_key]
        
        # Check custom config
        if key in self.custom_config:
            return self.custom_config[key]
        
        # Check settings
        if hasattr(self.settings, key):
            return getattr(self.settings, key)
        
        return default
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert configuration to dictionary."""
        config_dict = self.settings.dict()
        config_dict.update(self.custom_config)
        return config_dict

# Usage example
def setup_module_config() -> ConfigManager:
    """Setup module configuration."""
    config = ConfigManager()
    
    # Load from file if exists
    if os.path.exists('config/module.yaml'):
        config.load_from_file('config/module.yaml')
    
    # Override with environment variables
    # (handled automatically by pydantic)
    
    return config
"""
ANCHOR_END: module_config
```

Testing Custom Modules

Comprehensive Test Suite

```python
"""
ANCHOR: module_tests
"""
import pytest
import asyncio
from unittest.mock import AsyncMock, patch, MagicMock
import sys
import os

# Add module to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from src.my_blux_module.core import BLUXModule, ModuleConfig, ModuleStatus
from src.my_blux_module.specialized import DataAnalysisModule

class TestBLUXModule:
    """Test base BLUX module functionality."""
    
    @pytest.fixture
    def module_config(self):
        """Create test module configuration."""
        return ModuleConfig(
            name="test-module",
            version="1.0.0",
            max_concurrent_tasks=2
        )
    
    @pytest.fixture
    async def blux_module(self, module_config):
        """Create test module instance."""
        module = BLUXModule(module_config)
        yield module
        # Cleanup
        for task in module.active_tasks.values():
            task.cancel()
    
    @pytest.mark.asyncio
    async def test_module_initialization(self, blux_module, module_config):
        """Test module initialization."""
        await blux_module.initialize()
        
        assert blux_module.status == ModuleStatus.READY
        assert blux_module.config == module_config
    
    @pytest.mark.asyncio
    async def test_capabilities(self, blux_module):
        """Test capabilities reporting."""
        capabilities = blux_module.get_capabilities()
        
        assert isinstance(capabilities, dict)
        assert 'data_processing' in capabilities
        assert 'audit_integration' in capabilities
    
    @pytest.mark.asyncio
    async def test_health_check(self, blux_module):
        """Test health check."""
        await blux_module.initialize()
        health = await blux_module.health_check()
        
        assert health['status'] == 'ready'
        assert health['module'] == 'test-module'
        assert health['version'] == '1.0.0'

class TestDataAnalysisModule:
    """Test data analysis module functionality."""
    
    @pytest.fixture
    async def analysis_module(self):
        """Create test analysis module."""
        config = ModuleConfig(
            name="test-analysis-module",
            version="1.0.0"
        )
        module = DataAnalysisModule(config)
        await module.initialize()
        yield module
        
        # Cleanup
        for task in module.active_tasks.values():
            task.cancel()
    
    @pytest.mark.asyncio
    async def test_statistical_analysis(self, analysis_module):
        """Test statistical analysis."""
        test_data = {"values": [1, 2, 3, 4, 5]}
        result = await analysis_module._statistical_analysis(test_data, {})
        
        assert result['mean'] == 3.0
        assert result['min'] == 1
        assert result['max'] == 5
        assert result['count'] == 5
    
    @pytest.mark.asyncio
    async def test_pattern_analysis(self, analysis_module):
        """Test pattern analysis."""
        increasing_data = {"values": [1, 2, 3, 4, 5]}
        result = await analysis_module._pattern_analysis(increasing_data, {})
        
        assert "increasing_sequence" in result['patterns_detected']
        assert result['pattern_count'] == 1
    
    @pytest.mark.asyncio
    async def test_trend_analysis(self, analysis_module):
        """Test trend analysis."""
        increasing_data = {"values": [1, 2, 3, 4, 5]}
        result = await analysis_module._trend_analysis(increasing_data, {})
        
        assert result['trend'] == 'increasing'
        assert result['change_percentage'] == 400.0  # (5-1)/1 * 100

    @pytest.mark.asyncio
    async def test_full_analysis_workflow(self, analysis_module):
        """Test complete analysis workflow."""
        task_data = {
            "analysis_type": "statistical",
            "data": {"values": [10, 20, 30, 40, 50]},
            "parameters": {}
        }
        
        result = await analysis_module.process_task(task_data)
        
        assert result['analysis_type'] == 'statistical'
        assert 'result' in result
        assert 'metadata' in result
        assert result['metadata']['data_points'] == 5

# Integration tests
@pytest.mark.integration
class TestModuleIntegration:
    """Integration tests for module with BLUX ecosystem."""
    
    @pytest.mark.asyncio
    async def test_module_registration(self):
        """Test module registration with BLUX Lite."""
        # This would test actual registration with a test BLUX instance
        pass
    
    @pytest.mark.asyncio 
    async def test_audit_integration(self):
        """Test audit system integration."""
        # This would test audit recording with blux-guard
        pass

# Mock testing for external dependencies
@pytest.mark.asyncio
async def test_with_mocked_dependencies():
    """Test with mocked BLUX services."""
    with patch('aiohttp.ClientSession') as mock_session:
        # Setup mock responses
        mock_response = AsyncMock()
        mock_response.json.return_value = {"status": "registered"}
        mock_session.post.return_value.__aenter__.return_value = mock_response
        
        # Test module initialization
        config = ModuleConfig(name="test-module")
        module = BLUXModule(config)
        
        await module._register_module()
        
        # Verify mock was called
        mock_session.post.assert_called_once()

# Performance tests
@pytest.mark.performance
class TestModulePerformance:
    """Performance tests for the module."""
    
    @pytest.mark.asyncio
    async def test_concurrent_processing(self):
        """Test processing multiple tasks concurrently."""
        config = ModuleConfig(
            name="perf-test-module",
            max_concurrent_tasks=5
        )
        module = DataAnalysisModule(config)
        await module.initialize()
        
        # Submit multiple tasks
        tasks = []
        for i in range(10):
            task_data = {
                "analysis_type": "statistical",
                "data": {"values": list(range(i, i + 10))},
                "parameters": {}
            }
            tasks.append(module.process_task(task_data))
        
        # Process concurrently
        results = await asyncio.gather(*tasks, return_exceptions=True)
        
        # Verify all tasks completed
        assert len(results) == 10
        assert all(not isinstance(r, Exception) for r in results)
        
        # Cleanup
        for task in module.active_tasks.values():
            task.cancel()

# Configuration tests
def test_configuration_validation():
    """Test configuration validation."""
    from src.my_blux_module.config import ModuleSettings
    
    # Test valid configuration
    valid_config = ModuleSettings(
        module_name="test-module",
        environment="development",
        audit_level="detailed"
    )
    assert valid_config.module_name == "test-module"
    
    # Test invalid configuration
    with pytest.raises(ValueError):
        ModuleSettings(environment="invalid")
    
    with pytest.raises(ValueError):
        ModuleSettings(audit_level="invalid")
"""
ANCHOR_END: module_tests
```

Deployment Configuration

Docker Configuration

```dockerfile
"""
ANCHOR: docker_config
"""
# Dockerfile for BLUX module
FROM python:3.9-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -u 1000 blux
USER blux

# Set working directory
WORKDIR /app

# Copy requirements first for better caching
COPY --chown=blux:blux requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY --chown=blux:blux src/ ./src/
COPY --chown=blux:blux scripts/ ./scripts/
COPY --chown=blux:blux manifests/ ./manifests/

# Create necessary directories
RUN mkdir -p logs data

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Start command
CMD ["python", "-m", "src.my_blux_module.api"]
"""
ANCHOR_END: docker_config
```

Kubernetes Deployment

```yaml
"""
ANCHOR: kubernetes_config
"""
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-blux-module
  labels:
    app: my-blux-module
    component: processor
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-blux-module
  template:
    metadata:
      labels:
        app: my-blux-module
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8000"
        prometheus.io/path: "/metrics"
    spec:
      containers:
      - name: module
        image: my-registry/blux-module:1.0.0
        ports:
        - containerPort: 8000
        env:
        - name: BLUX_ENV
          value: "production"
        - name: BLUX_LITE_HOST
          value: "blux-lite.blux.svc.cluster.local"
        - name: BLUX_GUARD_HOST
          value: "blux-guard.blux.svc.cluster.local"
        - name: BLUX_MODULE_MAX_CONCURRENT_TASKS
          value: "10"
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
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: my-blux-module
spec:
  selector:
    app: my-blux-module
  ports:
  - port: 8000
    targetPort: 8000
  type: ClusterIP
"""
ANCHOR_END: kubernetes_config
```

Integration with BLUX Ecosystem

Service Discovery

```python
"""
ANCHOR: service_discovery
"""
import aiohttp
import asyncio
from typing import Dict, Any, Optional

class BLUXServiceDiscovery:
    """
    Handles service discovery within BLUX ecosystem.
    Finds and connects to other BLUX services.
    """
    
    def __init__(self, blux_lite_host: str):
        self.blux_lite_host = blux_lite_host
        self.service_cache: Dict[str, Dict] = {}
        self.cache_ttl = 300  # 5 minutes
        self.last_update: Dict[str, float] = {}
    
    async def discover_services(self) -> Dict[str, Dict]:
        """Discover all available BLUX services."""
        try:
            async with aiohttp.ClientSession() as session:
                async with session.get(
                    f"http://{self.blux_lite_host}/v1/services",
                    timeout=aiohttp.ClientTimeout(total=10)
                ) as response:
                    if response.status == 200:
                        services = await response.json()
                        self.service_cache = services
                        self.last_update['services'] = asyncio.get_event_loop().time()
                        return services
                    else:
                        raise Exception(f"Service discovery failed: {response.status}")
                        
        except Exception as e:
            print(f"Service discovery error: {e}")
            # Return cached services if available
            if self.service_cache and self._is_cache_valid('services'):
                return self.service_cache
            raise
    
    async def find_service(self, service_name: str) -> Optional[Dict]:
        """Find specific service by name."""
        services = await self.discover_services()
        return services.get(service_name)
    
    async def get_service_endpoint(self, service_name: str, endpoint: str) -> str:
        """Get full endpoint URL for a service."""
        service = await self.find_service(service_name)
        if service and 'endpoints' in service:
            base_url = service.get('endpoint', f'http://{service_name}')
            return f"{base_url}/{endpoint.lstrip('/')}"
        else:
            raise Exception(f"Service {service_name} not found or no endpoints")
    
    def _is_cache_valid(self, cache_key: str) -> bool:
        """Check if cache is still valid."""
        if cache_key not in self.last_update:
            return False
        
        current_time = asyncio.get_event_loop().time()
        return (current_time - self.last_update[cache_key]) < self.cache_ttl

# Usage in module
async def setup_service_discovery(module: BLUXModule) -> BLUXServiceDiscovery:
    """Setup service discovery for module."""
    discovery = BLUXServiceDiscovery(module.config.blux_lite_host)
    
    try:
        services = await discovery.discover_services()
        print(f"Discovered {len(services)} BLUX services")
        return discovery
    except Exception as e:
        print(f"Service discovery failed: {e}")
        # Continue with default configuration
        return discovery
"""
ANCHOR_END: service_discovery
```

---

Custom modules extend the constellation, each bringing unique light to the whole.  (( • ))

Next Steps:

1. Implement your module logic in the process_task method
2. Configure your module in manifests/module.manifest.json
3. Write comprehensive tests for your functionality
4. Deploy and integrate with your BLUX ecosystem

Remember to follow BLUX principles: Reflection > Reaction, Coordination > Concentration, Coherence > Complexity, Principles > Preferences.

---
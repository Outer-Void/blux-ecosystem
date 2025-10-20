#!/usr/bin/env python3
"""
BLUX Configuration Validator
Validates configuration files and environment setup.
"""

import json
import yaml
import os
import sys
from pathlib import Path
from typing import Dict, Any, List, Optional
import argparse


class ConfigValidator:
    """Validates BLUX configuration files."""
    
    def __init__(self):
        self.errors = []
        self.warnings = []
        
    def validate_json_file(self, file_path: Path, schema: Optional[Dict] = None) -> bool:
        """Validate a JSON configuration file."""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = json.load(f)
                
            # Basic structure validation
            if file_path.name == "hub.manifest.json":
                return self._validate_hub_manifest(content)
            elif file_path.name == "policy.doctrine.json":
                return self._validate_doctrine_policy(content)
            else:
                # Generic JSON validation
                if not isinstance(content, dict):
                    self.errors.append(f"{file_path}: Root must be an object")
                    return False
                return True
                
        except json.JSONDecodeError as e:
            self.errors.append(f"{file_path}: Invalid JSON - {e}")
            return False
        except Exception as e:
            self.errors.append(f"{file_path}: Validation error - {e}")
            return False
    
    def validate_yaml_file(self, file_path: Path) -> bool:
        """Validate a YAML configuration file."""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = yaml.safe_load(f)
                
            if file_path.name.endswith(('.yaml', '.yml')):
                if not isinstance(content, dict):
                    self.errors.append(f"{file_path}: Root must be a mapping")
                    return False
                    
                # Environment-specific validations
                if "development.yaml" in file_path.name:
                    return self._validate_development_config(content)
                elif "production.yaml" in file_path.name:
                    return self._validate_production_config(content)
                    
            return True
            
        except yaml.YAMLError as e:
            self.errors.append(f"{file_path}: Invalid YAML - {e}")
            return False
        except Exception as e:
            self.errors.append(f"{file_path}: Validation error - {e}")
            return False
    
    def _validate_hub_manifest(self, manifest: Dict) -> bool:
        """Validate hub manifest structure."""
        required_fields = ['version', 'cluster', 'release_date', 'services']
        
        for field in required_fields:
            if field not in manifest:
                self.errors.append(f"Hub manifest missing required field: {field}")
                return False
                
        # Validate services structure
        services = manifest.get('services', {})
        for service_name, service_config in services.items():
            if not isinstance(service_config, dict):
                self.errors.append(f"Service {service_name} must be an object")
                continue
                
            if 'version' not in service_config:
                self.warnings.append(f"Service {service_name} missing version")
            if 'endpoint' not in service_config:
                self.warnings.append(f"Service {service_name} missing endpoint")
                
        return True
    
    def _validate_doctrine_policy(self, policy: Dict) -> bool:
        """Validate doctrine policy structure."""
        required_fields = ['doctrine_version', 'effective_date', 'flags']
        
        for field in required_fields:
            if field not in policy:
                self.errors.append(f"Doctrine policy missing required field: {field}")
                return False
                
        # Validate flags
        flags = policy.get('flags', {})
        expected_flags = [
            'require_reflection', 'sandbox_all_operations', 
            'audit_all_requests', 'validate_all_signatures'
        ]
        
        for flag in expected_flags:
            if flag not in flags:
                self.warnings.append(f"Doctrine policy missing expected flag: {flag}")
                
        return True
    
    def _validate_development_config(self, config: Dict) -> bool:
        """Validate development configuration."""
        # Development should have relaxed security
        security = config.get('security', {})
        if security.get('require_authentication') is True:
            self.warnings.append("Development config has require_authentication=true")
            
        return True
    
    def _validate_production_config(self, config: Dict) -> bool:
        """Validate production configuration."""
        # Production should have strict security
        security = config.get('security', {})
        if security.get('require_authentication') is not True:
            self.warnings.append("Production config should have require_authentication=true")
            
        if security.get('require_mtls') is not True:
            self.warnings.append("Production config should have require_mtls=true")
            
        return True
    
    def validate_environment(self) -> bool:
        """Validate environment variables."""
        required_vars = ['BLUX_ENV']
        optional_vars = [
            'BLUX_AUDIT_PATH', 'BLUX_LOG_PATH', 'BLUX_DATA_PATH',
            'BLUX_REG_HOST', 'BLUX_LITE_HOST', 'BLUX_GUARD_HOST'
        ]
        
        for var in required_vars:
            if var not in os.environ:
                self.errors.append(f"Required environment variable not set: {var}")
                
        for var in optional_vars:
            if var not in os.environ:
                self.warnings.append(f"Optional environment variable not set: {var}")
                
        return len([e for e in self.errors if 'environment variable' in e]) == 0
    
    def validate_directory_structure(self, base_path: Path) -> bool:
        """Validate expected directory structure."""
        expected_dirs = [
            'scripts',
            'docs',
            'manifests', 
            'config',
            'backups',
            'patches'
        ]
        
        for dir_name in expected_dirs:
            dir_path = base_path / dir_name
            if not dir_path.exists():
                self.warnings.append(f"Expected directory not found: {dir_name}")
                
        return True
    
    def get_summary(self) -> Dict[str, Any]:
        """Get validation summary."""
        return {
            'valid': len(self.errors) == 0,
            'error_count': len(self.errors),
            'warning_count': len(self.warnings),
            'errors': self.errors,
            'warnings': self.warnings
        }
    
    def print_summary(self, output_format: str = "text"):
        """Print validation summary."""
        summary = self.get_summary()
        
        if output_format == "json":
            print(json.dumps(summary, indent=2))
            return
            
        # Text format
        print("BLUX Configuration Validation")
        print("=" * 40)
        
        if summary['error_count'] > 0:
            print(f"❌ Validation failed with {summary['error_count']} errors")
        elif summary['warning_count'] > 0:
            print(f"⚠️  Validation passed with {summary['warning_count']} warnings")
        else:
            print("✅ Validation passed")
            
        if summary['errors']:
            print("\nErrors:")
            for error in summary['errors']:
                print(f"  • {error}")
                
        if summary['warnings']:
            print("\nWarnings:")
            for warning in summary['warnings']:
                print(f"  • {warning}")


def main():
    parser = argparse.ArgumentParser(description="BLUX Configuration Validator")
    parser.add_argument("--check", action="store_true", 
                       help="Check configuration without full validation")
    parser.add_argument("--env", choices=["development", "production", "all"],
                       default="all", help="Environment to validate")
    parser.add_argument("--format", choices=["text", "json"], default="text",
                       help="Output format")
    parser.add_argument("--path", default=".", 
                       help="Path to BLUX root directory")
    
    args = parser.parse_args()
    
    base_path = Path(args.path).resolve()
    validator = ConfigValidator()
    
    print(f"Validating configuration in: {base_path}")
    
    # Validate directory structure
    validator.validate_directory_structure(base_path)
    
    # Validate configuration files
    config_files = [
        base_path / "manifests" / "hub.manifest.json",
        base_path / "manifests" / "policy.doctrine.json",
    ]
    
    # Add environment-specific configs
    if args.env in ["development", "all"]:
        config_files.append(base_path / "config" / "development.yaml")
    if args.env in ["production", "all"]:
        config_files.append(base_path / "config" / "production.yaml")
    
    for config_file in config_files:
        if config_file.exists():
            if config_file.suffix == '.json':
                validator.validate_json_file(config_file)
            elif config_file.suffix in ['.yaml', '.yml']:
                validator.validate_yaml_file(config_file)
        else:
            validator.warnings.append(f"Configuration file not found: {config_file.name}")
    
    # Validate environment if not in check mode
    if not args.check:
        validator.validate_environment()
    
    # Output results
    validator.print_summary(args.format)
    
    # Exit code based on validation result
    if not validator.get_summary()['valid']:
        sys.exit(1)


if __name__ == "__main__":
    main()
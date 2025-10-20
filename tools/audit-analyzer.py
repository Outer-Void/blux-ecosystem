#!/usr/bin/env python3
"""
BLUX Audit Analyzer
Analyzes JSONL audit trails for security, performance, and operational insights.
"""

import json
import argparse
import sys
from pathlib import Path
from datetime import datetime, timedelta
from collections import defaultdict, Counter
import statistics
from typing import Dict, List, Any, Optional


class AuditAnalyzer:
    """Analyzes BLUX audit trails."""
    
    def __init__(self, audit_path: str):
        self.audit_path = Path(audit_path)
        self.entries = []
        self.stats = defaultdict(lambda: defaultdict(int))
        
    def load_audit_files(self, time_range: Optional[timedelta] = None) -> int:
        """Load audit entries from JSONL files."""
        if not self.audit_path.exists():
            print(f"Error: Audit path not found: {self.audit_path}")
            return 0
            
        cutoff_time = None
        if time_range:
            cutoff_time = datetime.now() - time_range
            
        total_entries = 0
        
        # Find all JSONL files
        for audit_file in self.audit_path.glob("*.jsonl"):
            print(f"Loading: {audit_file.name}")
            with open(audit_file, 'r', encoding='utf-8') as f:
                for line_num, line in enumerate(f, 1):
                    try:
                        entry = json.loads(line.strip())
                        
                        # Filter by time if specified
                        if cutoff_time:
                            entry_time = datetime.fromisoformat(entry['timestamp'].replace('Z', '+00:00'))
                            if entry_time < cutoff_time:
                                continue
                                
                        self.entries.append(entry)
                        total_entries += 1
                        
                    except json.JSONDecodeError as e:
                        print(f"Warning: Invalid JSON in {audit_file}:{line_num} - {e}")
                    except KeyError as e:
                        print(f"Warning: Missing field in {audit_file}:{line_num} - {e}")
                        
        return total_entries
    
    def analyze_operations(self) -> Dict[str, Any]:
        """Analyze operation patterns and frequencies."""
        operations = Counter()
        services = Counter()
        users = Counter()
        response_times = []
        
        for entry in self.entries:
            operations[entry.get('operation', 'unknown')] += 1
            services[entry.get('service', 'unknown')] += 1
            users[entry.get('identity', 'unknown')] += 1
            
            # Extract response time if available
            if 'duration_ms' in entry:
                response_times.append(entry['duration_ms'])
                
        return {
            'total_operations': len(self.entries),
            'operations': dict(operations.most_common()),
            'services': dict(services.most_common()),
            'users': dict(users.most_common(10)),  # Top 10 users
            'response_times': {
                'count': len(response_times),
                'mean': statistics.mean(response_times) if response_times else 0,
                'median': statistics.median(response_times) if response_times else 0,
                'p95': statistics.quantiles(response_times, n=20)[18] if len(response_times) >= 20 else 0,
            } if response_times else {}
        }
    
    def analyze_security(self) -> Dict[str, Any]:
        """Analyze security-related patterns."""
        failed_operations = 0
        doctrine_violations = 0
        suspicious_patterns = []
        
        for entry in self.entries:
            # Check for failed operations
            if entry.get('status') == 'failure':
                failed_operations += 1
                
            # Check for doctrine violations
            doctrine_flags = entry.get('doctrine_flags_applied', [])
            if 'validation_failed' in doctrine_flags:
                doctrine_violations += 1
                
            # Detect suspicious patterns (basic)
            operation = entry.get('operation', '')
            if any(pattern in operation for pattern in ['unauthorized', 'failed', 'rejected']):
                suspicious_patterns.append(entry)
                
        return {
            'failed_operations': failed_operations,
            'doctrine_violations': doctrine_violations,
            'suspicious_patterns_count': len(suspicious_patterns),
            'suspicious_patterns': suspicious_patterns[:10]  # First 10 examples
        }
    
    def analyze_performance(self) -> Dict[str, Any]:
        """Analyze performance characteristics."""
        hourly_volume = Counter()
        service_volume = Counter()
        
        for entry in self.entries:
            # Group by hour
            try:
                entry_time = datetime.fromisoformat(entry['timestamp'].replace('Z', '+00:00'))
                hour_key = entry_time.strftime('%Y-%m-%d %H:00')
                hourly_volume[hour_key] += 1
            except (KeyError, ValueError):
                pass
                
            # Service volume
            service_volume[entry.get('service', 'unknown')] += 1
            
        return {
            'hourly_volume': dict(hourly_volume),
            'service_volume': dict(service_volume),
            'peak_hour': hourly_volume.most_common(1)[0] if hourly_volume else None,
        }
    
    def generate_report(self, analysis_type: str = "full") -> Dict[str, Any]:
        """Generate analysis report."""
        report = {
            'metadata': {
                'generated_at': datetime.now().isoformat(),
                'total_entries': len(self.entries),
                'time_range': {
                    'start': min((e['timestamp'] for e in self.entries), default=None),
                    'end': max((e['timestamp'] for e in self.entries), default=None),
                } if self.entries else {}
            }
        }
        
        if analysis_type in ["full", "operations"]:
            report['operations'] = self.analyze_operations()
            
        if analysis_type in ["full", "security"]:
            report['security'] = self.analyze_security()
            
        if analysis_type in ["full", "performance"]:
            report['performance'] = self.analyze_performance()
            
        return report
    
    def print_report(self, report: Dict[str, Any], output_format: str = "text"):
        """Print analysis report in specified format."""
        if output_format == "json":
            print(json.dumps(report, indent=2))
            return
            
        # Text format output
        print("BLUX Audit Analysis Report")
        print("=" * 50)
        print(f"Generated: {report['metadata']['generated_at']}")
        print(f"Total entries: {report['metadata']['total_entries']:,}")
        
        if 'operations' in report:
            ops = report['operations']
            print(f"\nOperations Analysis:")
            print(f"  Total operations: {ops['total_operations']:,}")
            print(f"  Top operations:")
            for op, count in list(ops['operations'].items())[:5]:
                print(f"    {op}: {count:,}")
                
            if ops['response_times']:
                rt = ops['response_times']
                print(f"  Response times (ms):")
                print(f"    Mean: {rt['mean']:.1f}, Median: {rt['median']:.1f}, P95: {rt['p95']:.1f}")
        
        if 'security' in report:
            sec = report['security']
            print(f"\nSecurity Analysis:")
            print(f"  Failed operations: {sec['failed_operations']:,}")
            print(f"  Doctrine violations: {sec['doctrine_violations']:,}")
            print(f"  Suspicious patterns: {sec['suspicious_patterns_count']:,}")
            
        if 'performance' in report:
            perf = report['performance']
            if perf['peak_hour']:
                hour, count = perf['peak_hour']
                print(f"\nPerformance Analysis:")
                print(f"  Peak hour: {hour} ({count:,} operations)")
                print(f"  Service distribution:")
                for service, count in list(perf['service_volume'].items())[:5]:
                    print(f"    {service}: {count:,}")


def main():
    parser = argparse.ArgumentParser(description="BLUX Audit Analyzer")
    parser.add_argument("--audit-path", default="~/.config/blux/audit/", 
                       help="Path to audit files (default: ~/.config/blux/audit/)")
    parser.add_argument("--last", help="Analyze last N hours/days (e.g., 24h, 7d)")
    parser.add_argument("--type", choices=["full", "operations", "security", "performance"],
                       default="full", help="Type of analysis to perform")
    parser.add_argument("--format", choices=["text", "json"], default="text",
                       help="Output format")
    parser.add_argument("--output", help="Output file (default: stdout)")
    
    args = parser.parse_args()
    
    # Expand user directory
    audit_path = Path(args.audit_path).expanduser()
    
    # Parse time range
    time_range = None
    if args.last:
        if args.last.endswith('h'):
            hours = int(args.last[:-1])
            time_range = timedelta(hours=hours)
        elif args.last.endswith('d'):
            days = int(args.last[:-1])
            time_range = timedelta(days=days)
        else:
            print("Error: Time range must end with 'h' (hours) or 'd' (days)")
            sys.exit(1)
    
    # Analyze
    analyzer = AuditAnalyzer(audit_path)
    total_loaded = analyzer.load_audit_files(time_range)
    
    if total_loaded == 0:
        print("No audit entries found.")
        sys.exit(1)
        
    print(f"Loaded {total_loaded:,} audit entries")
    
    report = analyzer.generate_report(args.type)
    
    # Output
    if args.output:
        with open(args.output, 'w', encoding='utf-8') as f:
            if args.format == "json":
                json.dump(report, f, indent=2)
            else:
                # For text output to file, we need to capture print output
                import io
                from contextlib import redirect_stdout
                
                output = io.StringIO()
                with redirect_stdout(output):
                    analyzer.print_report(report, "text")
                f.write(output.getvalue())
    else:
        analyzer.print_report(report, args.format)


if __name__ == "__main__":
    main()
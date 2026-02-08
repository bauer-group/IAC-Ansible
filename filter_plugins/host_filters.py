"""
IAC-Ansible: Custom Filter Plugins for Host Filtering
======================================================
Includes hostname decoder for the AAAA-GG.cloud.bauer-group.com schema.

Usage in playbooks:
  {{ inventory_hostname | parse_asset_hostname }}
  {{ inventory_hostname | asset_id }}
  {{ inventory_hostname | group_code }}
  {{ inventory_hostname | asset_type }}
  {{ groups['all'] | filter_by_label('production', hostvars) }}
"""

import fnmatch
import re

# Group code to asset type mapping (AAAA-GG schema)
GROUP_CODE_MAP = {
    "00": "physical_server",
    "05": "physical_cluster_node",
    "10": "vm_private_cloud",
    "15": "vm_cluster",
    "20": "public_cloud_vm",
    "25": "public_cloud_managed",
    "30": "cloud_service_physical",
    "35": "cloud_service_vm",
    "40": "network_device",
    "45": "storage",
    "48": "security_firewall",
    "50": "production_external",
    "55": "production_internal",
    "60": "development",
    "61": "staging",
    "68": "test_sandbox",
    "70": "monitoring",
    "71": "logging",
    "72": "backup",
    "78": "management_tooling",
    "80": "iot_gateway",
    "85": "iot_node",
    "88": "edge_device",
}

# Regex: AAAA-GG.cloud.bauer-group.com (or just AAAA-GG as prefix)
HOSTNAME_PATTERN = re.compile(r'^(\d{4})-(\d{2})(?:\.cloud\.bauer-group\.com)?$')


def parse_asset_hostname(hostname):
    """Parse AAAA-GG hostname into structured metadata.

    Returns dict with asset_id, group_code, asset_type, valid.
    """
    match = HOSTNAME_PATTERN.match(hostname)
    if not match:
        return {"asset_id": None, "group_code": None, "asset_type": None, "valid": False}

    asset_id = match.group(1)
    group_code = match.group(2)
    asset_type = GROUP_CODE_MAP.get(group_code, "unknown_" + group_code)

    return {
        "asset_id": asset_id,
        "group_code": group_code,
        "asset_type": asset_type,
        "valid": True,
    }


def asset_id(hostname):
    """Extract asset ID from hostname. Returns '0046' from '0046-20.cloud.bauer-group.com'."""
    parsed = parse_asset_hostname(hostname)
    return parsed["asset_id"] or ""


def group_code(hostname):
    """Extract group code from hostname. Returns '20' from '0046-20.cloud.bauer-group.com'."""
    parsed = parse_asset_hostname(hostname)
    return parsed["group_code"] or ""


def asset_type(hostname):
    """Extract asset type from hostname. Returns 'public_cloud_vm' for group code 20."""
    parsed = parse_asset_hostname(hostname)
    return parsed["asset_type"] or ""


def filter_by_group_range(hosts, start, end):
    """Filter hosts by group code range.

    Usage:
      {{ groups['all'] | filter_by_group_range(20, 29) }}
    """
    result = []
    for host in hosts:
        parsed = parse_asset_hostname(host)
        if parsed["valid"]:
            code = int(parsed["group_code"])
            if start <= code <= end:
                result.append(host)
    return result


def filter_by_label(hosts, label, hostvars):
    """Filter hosts by label."""
    result = []
    for host in hosts:
        host_labels = hostvars.get(host, {}).get('labels', [])
        if label in host_labels:
            result.append(host)
    return result


def matches_pattern(hostname, pattern):
    """Check if hostname matches a wildcard pattern."""
    return fnmatch.fnmatch(hostname, pattern)


def matches_regex(hostname, regex):
    """Check if hostname matches a regex pattern."""
    return bool(re.match(regex, hostname))


def has_service(services, service_name):
    """Check if a service is in the services list."""
    if not services:
        return False
    return service_name in services


def filter_by_platform(hosts, platform, hostvars):
    """Filter hosts by platform identifier."""
    result = []
    for host in hosts:
        host_platform = hostvars.get(host, {}).get('platform', '')
        if fnmatch.fnmatch(host_platform, platform):
            result.append(host)
    return result


class FilterModule:
    """Ansible filter plugin registration."""

    def filters(self):
        return {
            'parse_asset_hostname': parse_asset_hostname,
            'asset_id': asset_id,
            'group_code': group_code,
            'asset_type': asset_type,
            'filter_by_group_range': filter_by_group_range,
            'filter_by_label': filter_by_label,
            'matches_pattern': matches_pattern,
            'matches_regex': matches_regex,
            'has_service': has_service,
            'filter_by_platform': filter_by_platform,
        }

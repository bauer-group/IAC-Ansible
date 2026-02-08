"""
IAS-Ansible: Custom Filter Plugins for Host Filtering
======================================================
These filters enable advanced host selection and data transformation
in playbooks and templates.

Usage in playbooks:
  {{ groups['all'] | filter_by_label('production') }}
  {{ inventory_hostname | matches_pattern('*.bauer-group.com') }}
  {{ services | has_service('nginx') }}
"""

import fnmatch
import re


def filter_by_label(hosts, label, hostvars):
    """Filter hosts by label.

    Usage:
      {{ groups['all'] | filter_by_label('cloud', hostvars) }}
    """
    result = []
    for host in hosts:
        host_labels = hostvars.get(host, {}).get('labels', [])
        if label in host_labels:
            result.append(host)
    return result


def matches_pattern(hostname, pattern):
    """Check if hostname matches a wildcard pattern.

    Usage:
      when: inventory_hostname | matches_pattern('*.bauer-group.com')
    """
    return fnmatch.fnmatch(hostname, pattern)


def matches_regex(hostname, regex):
    """Check if hostname matches a regex pattern.

    Usage:
      when: inventory_hostname | matches_regex('^web-\\d+\\.example\\.com$')
    """
    return bool(re.match(regex, hostname))


def has_service(services, service_name):
    """Check if a service is in the services list.

    Usage:
      when: services | default([]) | has_service('nginx')
    """
    if not services:
        return False
    return service_name in services


def filter_by_platform(hosts, platform, hostvars):
    """Filter hosts by platform identifier.

    Usage:
      {{ groups['all'] | filter_by_platform('ubuntu_2404', hostvars) }}
    """
    result = []
    for host in hosts:
        host_platform = hostvars.get(host, {}).get('platform', '')
        if fnmatch.fnmatch(host_platform, platform):
            result.append(host)
    return result


def to_cron_schedule(minute="*", hour="*", day="*", month="*", weekday="*"):
    """Build a cron schedule string from components.

    Usage:
      {{ None | to_cron_schedule(minute='0', hour='3', weekday='0') }}
    """
    return f"{minute} {hour} {day} {month} {weekday}"


class FilterModule:
    """Ansible filter plugin registration."""

    def filters(self):
        return {
            'filter_by_label': filter_by_label,
            'matches_pattern': matches_pattern,
            'matches_regex': matches_regex,
            'has_service': has_service,
            'filter_by_platform': filter_by_platform,
            'to_cron_schedule': to_cron_schedule,
        }

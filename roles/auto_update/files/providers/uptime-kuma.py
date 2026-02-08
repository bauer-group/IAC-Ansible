#!/usr/bin/env python3
"""
IAC-Ansible: Uptime Kuma Status Monitor Provider
=================================================
Pluggable provider for the IAC-Ansible status monitor integration.
Discovers monitors automatically by matching the server's FQDN against
monitor names, URLs, and hostnames in Uptime Kuma.

Environment variables (set by iac-status-monitor.sh):
  STATUS_MONITOR_URL        - Uptime Kuma base URL
  STATUS_MONITOR_API_KEY    - API key for authentication
  STATUS_MONITOR_HOSTNAME   - Optional: override FQDN for discovery
  STATUS_MONITOR_STATE_FILE - Path to persist maintenance window ID
"""

import os
import sys
import socket

from uptime_kuma_api import UptimeKumaApi, MaintenanceStrategy

LOG_PREFIX = "[IAC-StatusMonitor:kuma]"


def get_search_names():
    """Return list of hostnames to search for in Uptime Kuma."""
    override = os.environ.get("STATUS_MONITOR_HOSTNAME", "").strip()
    if override:
        return [override]

    fqdn = socket.getfqdn()
    short = socket.gethostname()
    names = [fqdn]
    if short != fqdn:
        names.append(short)
    return names


def find_monitors(api, search_names):
    """Find monitors matching any of the search names."""
    monitors = api.get_monitors()
    matched = []
    seen_ids = set()

    for monitor in monitors:
        mon_name = monitor.get("name", "").lower()
        mon_url = monitor.get("url", "").lower()
        mon_hostname = monitor.get("hostname", "").lower()
        mon_id = monitor.get("id")

        for name in search_names:
            needle = name.lower()
            if needle in mon_name or needle in mon_url or needle in mon_hostname:
                if mon_id not in seen_ids:
                    matched.append(monitor)
                    seen_ids.add(mon_id)
                break

    return matched


def start(api, state_file):
    """Create a maintenance window for monitors matching this host."""
    search_names = get_search_names()
    print("{} Searching for monitors matching: {}".format(
        LOG_PREFIX, ", ".join(search_names)))

    monitors = find_monitors(api, search_names)

    if not monitors:
        print("{} No monitors found for this host, skipping".format(LOG_PREFIX))
        return

    monitor_names = [m["name"] for m in monitors]
    print("{} Found {} monitor(s): {}".format(
        LOG_PREFIX, len(monitors), ", ".join(monitor_names)))

    hostname = search_names[0]
    result = api.add_maintenance(
        title="IAC-Ansible: Maintenance on {}".format(hostname),
        strategy=MaintenanceStrategy.MANUAL,
        active=True,
        description="Automated maintenance window for system updates",
    )
    maintenance_id = result["id"]

    api.add_monitor_maintenance(
        maintenance_id,
        [{"id": m["id"]} for m in monitors],
    )

    os.makedirs(os.path.dirname(state_file), exist_ok=True)
    with open(state_file, "w") as f:
        f.write(str(maintenance_id))

    print("{} Maintenance window opened (ID: {})".format(
        LOG_PREFIX, maintenance_id))


def stop(api, state_file):
    """Close an active maintenance window."""
    if not os.path.exists(state_file):
        print("{} No active maintenance window found".format(LOG_PREFIX))
        return

    with open(state_file) as f:
        content = f.read().strip()
        if not content:
            print("{} Empty state file, cleaning up".format(LOG_PREFIX))
            os.remove(state_file)
            return
        maintenance_id = int(content)

    try:
        api.delete_maintenance(maintenance_id)
        print("{} Maintenance window closed (ID: {})".format(
            LOG_PREFIX, maintenance_id))
    except Exception as e:
        print("{} Could not delete maintenance {}: {}".format(
            LOG_PREFIX, maintenance_id, e))
    finally:
        if os.path.exists(state_file):
            os.remove(state_file)


def main():
    if len(sys.argv) < 2 or sys.argv[1] not in ("start", "stop"):
        print("Usage: {} start|stop".format(sys.argv[0]))
        sys.exit(1)

    action = sys.argv[1]
    url = os.environ["STATUS_MONITOR_URL"]
    api_key = os.environ["STATUS_MONITOR_API_KEY"]
    state_file = os.environ.get(
        "STATUS_MONITOR_STATE_FILE",
        "/var/lib/iac-ansible/maintenance-state",
    )

    api = UptimeKumaApi(url)
    try:
        api.login_by_token(api_key)

        if action == "start":
            start(api, state_file)
        elif action == "stop":
            stop(api, state_file)
    finally:
        api.disconnect()


if __name__ == "__main__":
    main()

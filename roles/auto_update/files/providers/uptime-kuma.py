#!/usr/bin/env python3
"""
IAC-Ansible: Uptime Kuma Status Monitor Provider
=================================================
Pluggable provider for the IAC-Ansible status monitor integration.
Discovers monitors automatically by matching the server's FQDN against
monitor names, URLs, and hostnames in Uptime Kuma.

Authentication:
  Uses username/password via the Socket.IO API (uptime-kuma-api library).

Maintenance lifecycle:
  start: Reuses existing maintenance entry if found, otherwise creates new.
         Sets active=True. Monitors are assigned by FQDN discovery.
  stop:  Sets active=False (maintenance completed). Entry stays in Kuma
         as a history record. Does NOT delete the entry.

Environment variables (set by iac-status-monitor.sh):
  STATUS_MONITOR_URL        - Uptime Kuma base URL
  STATUS_MONITOR_USERNAME   - Username for authentication
  STATUS_MONITOR_PASSWORD   - Password for authentication
  STATUS_MONITOR_HOSTNAME   - Optional: override FQDN for discovery
  STATUS_MONITOR_STATE_FILE - Path to persist maintenance window ID
"""

import os
import sys
import socket
from datetime import datetime, timezone

from uptime_kuma_api import UptimeKumaApi, MaintenanceStrategy

LOG_PREFIX = "[IAC-StatusMonitor:kuma]"
MAINTENANCE_TITLE_PREFIX = "IAC: Maintenance on "


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


def find_existing_maintenance(api, hostname):
    """Find an existing IAC-Ansible maintenance entry for this host."""
    expected_title = MAINTENANCE_TITLE_PREFIX + hostname
    try:
        maintenances = api.get_maintenances()
        for maint in maintenances:
            if maint.get("title") == expected_title:
                return maint
    except Exception:
        pass
    return None


def build_maintenance_params(hostname, description):
    """Build the required parameters for the Uptime Kuma maintenance API.

    MaintenanceStrategy.MANUAL still requires dateRange, weekdays, and
    daysOfMonth parameters per the uptime-kuma-api library.
    """
    today = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    return {
        "title": MAINTENANCE_TITLE_PREFIX + hostname,
        "strategy": MaintenanceStrategy.MANUAL,
        "active": True,
        "description": description,
        "intervalDay": 1,
        "dateRange": [
            "{} 00:00:00".format(today),
            "{} 23:59:00".format(today),
        ],
        "weekdays": [],
        "daysOfMonth": [],
    }


def start(api, state_file):
    """Open a maintenance window for monitors matching this host."""
    search_names = get_search_names()
    hostname = search_names[0]
    print("{} Searching for monitors matching: {}".format(
        LOG_PREFIX, ", ".join(search_names)))

    monitors = find_monitors(api, search_names)

    if not monitors:
        print("{} No monitors found for this host, skipping".format(LOG_PREFIX))
        return

    monitor_names = [m["name"] for m in monitors]
    print("{} Found {} monitor(s): {}".format(
        LOG_PREFIX, len(monitors), ", ".join(monitor_names)))

    # Reuse existing maintenance entry if available
    existing = find_existing_maintenance(api, hostname)
    now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M")
    description = "System updates started at {} UTC".format(now)

    if existing:
        maintenance_id = existing["id"]
        params = build_maintenance_params(hostname, description)
        api.edit_maintenance(maintenance_id, **params)
        print("{} Reactivated existing maintenance (ID: {})".format(
            LOG_PREFIX, maintenance_id))
    else:
        params = build_maintenance_params(hostname, description)
        result = api.add_maintenance(**params)
        maintenance_id = result["id"]
        print("{} Created new maintenance (ID: {})".format(
            LOG_PREFIX, maintenance_id))

    # Assign monitors to maintenance
    api.add_monitor_maintenance(
        maintenance_id,
        [{"id": m["id"]} for m in monitors],
    )

    os.makedirs(os.path.dirname(state_file), exist_ok=True)
    with open(state_file, "w") as f:
        f.write(str(maintenance_id))

    print("{} Maintenance window opened for: {}".format(
        LOG_PREFIX, ", ".join(monitor_names)))


def stop(api, state_file):
    """Close maintenance window (set inactive, keep as history)."""
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

    hostname = get_search_names()[0]
    now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M")
    description = "System updates completed at {} UTC".format(now)

    # Build full params (edit_maintenance requires title + strategy)
    params = build_maintenance_params(hostname, description)
    params["active"] = False

    try:
        api.edit_maintenance(maintenance_id, **params)
        print("{} Maintenance window closed (ID: {}, kept as history)".format(
            LOG_PREFIX, maintenance_id))
    except Exception as e:
        print("{} Could not deactivate maintenance {}: {}".format(
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
    username = os.environ["STATUS_MONITOR_USERNAME"]
    password = os.environ["STATUS_MONITOR_PASSWORD"]
    state_file = os.environ.get(
        "STATUS_MONITOR_STATE_FILE",
        "/var/lib/iac-ansible/maintenance-state",
    )

    api = UptimeKumaApi(url)
    try:
        api.login(username, password)

        if action == "start":
            start(api, state_file)
        elif action == "stop":
            stop(api, state_file)
    finally:
        api.disconnect()


if __name__ == "__main__":
    main()

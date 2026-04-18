# Architecture

## Overview

IAC-Ansible uses a **Git-based pull model** where each managed server periodically checks this repository for configuration changes and applies them automatically.

```
┌─────────────────────────────────────────────────────────┐
│                   GitHub Repository                      │
│                (bauer-group/IAC-Ansible)                 │
│                                                          │
│  inventory/ ─ playbooks/ ─ roles/ ─ scripts/            │
└───────────────┬────────────────────┬────────────────────┘
                │   git pull (daily) │   git pull (daily)
                ▼                    ▼
        ┌──────────────┐    ┌──────────────┐
        │   Server A   │    │   Server B   │
        │  ansible-pull│    │  ansible-pull│
        │  (systemd)   │    │  (systemd)   │
        └──────────────┘    └──────────────┘
```

## Components

### Pull Model (Primary)

Each server runs `ansible-pull` via a **systemd timer**:

1. Timer fires on schedule (default: daily at 02:00)
2. `ansible-pull` clones/updates the repo
3. Runs `playbooks/site.yml` for the local host
4. Applies only matching roles based on group membership

**Advantages:**
- No central server required
- Scales horizontally
- Servers are self-healing
- Works even if the network is intermittent

### Push Model (Optional)

For immediate updates, use the push script:

```bash
./scripts/push-update.sh 0046-20.cloud.bauer-group.com
# or
make push LIMIT="0046-20.cloud.bauer-group.com"
```

This SSHes to the target and triggers `systemctl start ansible-pull.service`.

### CI/CD Push (GitHub Actions)

On every push to `main`, GitHub Actions can automatically trigger updates on all managed hosts.

## Directory Structure

```
.
├── ansible.cfg                    # Ansible configuration
├── Makefile                       # Convenience commands
├── requirements.yml               # Galaxy dependencies
│
├── inventory/
│   ├── production/
│   │   ├── hosts.yml              # Production inventory
│   │   ├── group_vars/
│   │   │   └── all/
│   │   │       ├── main.yml       # Global variables
│   │   │       └── update_settings.yml  # Update configuration
│   │   └── host_vars/
│   │       └── <hostname>.yml     # Per-host overrides
│   └── staging/
│       └── ...
│
├── playbooks/
│   ├── site.yml                   # Master playbook (entry point)
│   ├── setup.yml                  # Initial host bootstrap
│   ├── update.yml                 # System updates
│   └── maintenance/
│       ├── reboot.yml             # Controlled reboot
│       └── cleanup.yml            # System cleanup
│
├── roles/
│   ├── common/                    # Base OS configuration (locale, NTP, DNS, fail2ban, msmtp, MOTD)
│   ├── ansible_pull/              # Git-based pull mechanism
│   ├── auto_update/               # Automatic system updates + maintenance chain
│   ├── docker/                    # Docker CE + Compose + IPv6 networking
│   └── smartmon/                  # SMART disk health monitoring
│
├── scripts/
│   ├── install.sh                 # One-line bootstrap installer
│   └── push-update.sh             # Push trigger script
│
├── filter_plugins/
│   └── host_filters.py            # Custom Jinja2 filters
│
├── docs/                          # Documentation
└── .github/workflows/             # CI/CD pipelines
```

## Role Dependency Graph

```
site.yml
  │
  ├── Phase 1: common           (all hosts)
  │   ├── Platform detection & packages
  │   ├── Locale (de_DE.UTF-8)
  │   ├── Timezone & NTP (with tuning)
  │   ├── Mail relay (msmtp)
  │   ├── DNS resolver hardening
  │   ├── fail2ban (SSH jail)
  │   ├── Open file limits (nofile)
  │   ├── Dynamic MOTD
  │   └── SSH hardening (opt-in)
  │
  ├── Phase 2: ansible_pull     (all hosts)
  │   ├── Install Ansible on host
  │   ├── systemd service + timer
  │   └── Logrotate
  │
  ├── Phase 3: auto_update      (auto_update group)
  │   ├── Maintenance chain script
  │   ├── unattended-upgrades config
  │   ├── Update cron job
  │   └── Conditional reboot with health checks
  │
  ├── Phase 4: docker           (docker_hosts group)
  │   ├── Docker CE + Compose plugin
  │   ├── IPv6 dual-stack networking
  │   ├── Docker daemon config (log rotation, storage)
  │   ├── sysctl tuning (vm.max_map_count)
  │   └── Weekly auto-prune
  │
  └── Phase 5: smartmon         (physical_servers group)
      ├── smartmontools + auto-detect disks
      ├── SMART health alerts via email
      └── smartcheck utility
```

## Platform Support

| Platform | Versions | Package Manager | Update Mechanism |
|----------|----------|-----------------|------------------|
| Ubuntu | 22.04, 24.04, 26.04 | apt | unattended-upgrades |
| Debian | 13 | apt | unattended-upgrades |
| RHEL | 9, 10 | dnf | dnf-automatic |
| Rocky | 9, 10 | dnf | dnf-automatic |
| AlmaLinux | 9, 10 | dnf | dnf-automatic |

Platform is auto-detected via `ansible_facts['os_family']` and `ansible_facts['distribution']`.

## Ansible Compatibility

| Requirement | Value |
|---|---|
| Minimum ansible-core | 2.18 (ansible >= 13.0) |
| Fact access syntax | `ansible_facts['...']` (migrated from deprecated `ansible_*` top-level injection) |
| Collections required | `community.general >= 12.0.0`, `ansible.posix >= 2.1.0` |

All fact access uses the `ansible_facts['...']` dictionary syntax. The deprecated `INJECT_FACTS_AS_VARS` top-level injection (`ansible_os_family`, `ansible_distribution`, etc.) is not used, ensuring compatibility with ansible-core 2.24+ where this feature will be removed.

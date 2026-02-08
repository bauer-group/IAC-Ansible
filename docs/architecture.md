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
│   ├── common/                    # Base OS configuration
│   ├── auto_update/               # Automatic system updates
│   └── ansible_pull/              # Git-based pull mechanism
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
  ├── common           (all hosts)
  │   ├── Platform detection
  │   ├── Package installation (apt/yum)
  │   ├── Timezone & NTP
  │   └── MOTD
  │
  ├── ansible_pull     (all hosts)
  │   ├── Install Ansible on host
  │   ├── systemd service + timer
  │   └── Logrotate
  │
  └── auto_update      (auto_update group only)
      ├── depends on: common
      ├── Update scripts (Debian/RedHat)
      ├── unattended-upgrades config
      ├── Update cron job
      └── Reboot cron job
```

## Platform Support

| Platform | Versions | Package Manager | Update Mechanism |
|----------|----------|-----------------|------------------|
| Ubuntu | 20.04, 22.04, 24.04 | apt | unattended-upgrades |
| Debian | 11, 12 | apt | unattended-upgrades |
| CentOS | 8, 9 | dnf/yum | dnf-automatic |
| RHEL | 8, 9 | dnf/yum | dnf-automatic |
| Rocky | 8, 9 | dnf/yum | dnf-automatic |
| AlmaLinux | 8, 9 | dnf/yum | dnf-automatic |

Platform is auto-detected via `ansible_os_family` and `ansible_distribution`.

# IAC-Ansible

Infrastructure as Code with Ansible - Git-based configuration management for BAUER GROUP.

## Quick Start

### Bootstrap a Server (One-Liner)

```bash
curl -fsSL https://raw.githubusercontent.com/bauer-group/IAC-Ansible/main/scripts/install.sh | bash
```

### Bootstrap with Inventory Hostname

For new hosts whose system hostname does not yet match the inventory entry
(e.g. a fresh provider image), set `IAC_HOSTNAME` so `ansible-pull` finds the
correct `host_vars/<name>.yml` on the first run:

```bash
curl -fsSL https://raw.githubusercontent.com/bauer-group/IAC-Ansible/main/scripts/install.sh | \
  IAC_HOSTNAME=0047-20.cloud.bauer-group.com bash
```

The installer runs `hostnamectl`, updates `/etc/hosts` and writes
`preserve_hostname: true` to `/etc/cloud/cloud.cfg` before the initial pull.
Idempotent — re-running with the same value is a no-op.

### Cloud-Init

```yaml
#cloud-config
runcmd:
  - curl -fsSL https://raw.githubusercontent.com/bauer-group/IAC-Ansible/main/scripts/install.sh | bash
```

### Control Machine

```bash
git clone https://github.com/bauer-group/IAC-Ansible.git
cd IAC-Ansible
make setup
make deploy
```

## Architecture

```
GitHub Repo  ──pull──>  Server A (ansible-pull, systemd timer)
             ──pull──>  Server B (ansible-pull, systemd timer)
             ──pull──>  Server C ...
```

Each server checks this Git repository daily for changes and applies them automatically. Alternatively, an immediate push can be triggered.

## Usage

```bash
make help                                      # Show all commands
make deploy                                    # Configure all servers
make deploy LIMIT=0046-20.cloud.bauer-group.com  # Specific host
make deploy LIMIT="*.bauer-group.com"          # Wildcard
make update                                    # Run system updates
make check                                     # Dry-run
make push LIMIT=<host>                         # Trigger immediate update
```

## Filtering

| Method | Example |
| --- | --- |
| Hostname | `LIMIT=server.example.com` |
| Wildcard | `LIMIT="*.bauer-group.com"` |
| IP range | `LIMIT="192.168.1.*"` |
| Group | `LIMIT=auto_update` |
| Label | `LABEL=production` |
| Service | `SERVICE=nginx` |
| Tags | `TAGS=update` |

## Directory Structure

```
inventory/         Hosts and variables (per environment)
playbooks/         Ansible playbooks
roles/             Reusable roles
  common/          Base configuration (all hosts)
  auto_update/     Automatic system updates
  ansible_pull/    Git-based pull mechanism
scripts/           Bootstrap and helper scripts
filter_plugins/    Custom Jinja2 filters
docs/              Documentation
```

## First Workflow: Auto-Updates

The host `0046-20.cloud.bauer-group.com` (Ubuntu 24.04) is configured with:

- **Updates**: Daily at 02:00 (all packages or security-only, configurable)
- **Reboot**: Sundays at 03:00 (only when required)
- **Control**: Centrally managed in `inventory/production/group_vars/all/update_settings.yml`

Switch between all updates and security-only:

```yaml
# inventory/production/group_vars/all/update_settings.yml
auto_update_type: "all"       # All updates
auto_update_type: "security"  # Security updates only
```

## Documentation

- [Architecture](docs/architecture.md)
- [Server Naming & Coding Scheme](docs/server-naming.md)
- [Quickstart](docs/quickstart.md)
- [Filtering](docs/filtering.md)
- [Auto-Updates](docs/auto-updates.md)
- [Cloud-Init](docs/cloud-init.md)
- [Inventory Management](docs/inventory-management.md)
- [Secrets Management](docs/vault.md)
- [Host Onboarding](docs/host-onboarding.md)
- [Workflows](docs/workflows.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Contributing](CONTRIBUTING.md)

## Platforms

| OS | Versions | Status |
| --- | --- | --- |
| Ubuntu | 22.04 LTS, 24.04 LTS, 26.04 LTS | Supported |
| Debian | 13 (trixie) | Supported |
| RHEL | 9, 10 | Supported |
| Rocky Linux | 9, 10 | Supported |
| AlmaLinux | 9, 10 | Supported |

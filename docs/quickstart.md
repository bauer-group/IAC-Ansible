# Quickstart Guide

## Prerequisites

- Git access to `https://github.com/bauer-group/IAC-Ansible.git`
- SSH access to target servers (root or sudo)

## 1. Bootstrap a New Server

### One-Line Installer

```bash
curl -fsSL https://raw.githubusercontent.com/bauer-group/IAC-Ansible/main/scripts/install.sh | bash
```

### With Custom Options

```bash
curl -fsSL https://raw.githubusercontent.com/bauer-group/IAC-Ansible/main/scripts/install.sh | \
  BRANCH=main SCHEDULE="*-*-* 02:00:00" bash
```

### With Inventory Hostname (for new hosts without cloud-init)

`ansible-pull` looks itself up in the inventory via the system's FQDN. On a
fresh provider image the hostname is usually `ubuntu` or `localhost` and the
match fails, so `host_vars/<name>.yml` is never loaded. Pass `IAC_HOSTNAME` to
let the installer set the hostname (via `hostnamectl`, `/etc/hosts` and
`preserve_hostname: true` in `/etc/cloud/cloud.cfg`) before the first pull:

```bash
curl -fsSL https://raw.githubusercontent.com/bauer-group/IAC-Ansible/main/scripts/install.sh | \
  IAC_HOSTNAME=0047-20.cloud.bauer-group.com bash
```

Combinable with the other variables:

```bash
curl -fsSL https://raw.githubusercontent.com/bauer-group/IAC-Ansible/main/scripts/install.sh | \
  IAC_HOSTNAME=0047-20.cloud.bauer-group.com BRANCH=main bash
```

The step is idempotent — running the installer again with the same
`IAC_HOSTNAME` value is a no-op.

### Cloud-Init

Add to your cloud-init user-data:

```yaml
#cloud-config
runcmd:
  - curl -fsSL https://raw.githubusercontent.com/bauer-group/IAC-Ansible/main/scripts/install.sh | bash
```

## 2. Add Server to Inventory

Edit `inventory/production/hosts.yml`:

```yaml
    auto_update:
      hosts:
        your-new-server.example.com:
          ansible_host: your-new-server.example.com
          platform: ubuntu_2404
          labels:
            - production
            - web
```

Commit and push. The server will pick up the changes on its next pull cycle.

## 3. Manage from Control Machine

### Install Requirements

```bash
make setup
```

### Deploy to All Hosts

```bash
make deploy
```

### Deploy to Specific Host

```bash
make deploy LIMIT=0046-20.cloud.bauer-group.com
```

### Run Updates

```bash
make update
```

### Check Mode (Dry Run)

```bash
make check
```

## 4. Change Configuration

All configuration is centralized in:

| What | Where |
|------|-------|
| Global settings | `inventory/production/group_vars/all/main.yml` |
| Update schedule & behavior | `inventory/production/group_vars/all/update_settings.yml` |
| Per-host overrides | `inventory/production/host_vars/<hostname>.yml` |

After changing, commit and push. Servers will auto-apply on next pull.

## 5. Trigger Immediate Update

```bash
make push LIMIT="0046-20.cloud.bauer-group.com"
```

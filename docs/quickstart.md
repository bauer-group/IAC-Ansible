# Quickstart Guide

## Prerequisites

- Git access to `https://github.com/bauer-group/IAS-Ansible.git`
- SSH access to target servers (root or sudo)

## 1. Bootstrap a New Server

### One-Line Installer

```bash
curl -fsSL https://raw.githubusercontent.com/bauer-group/IAS-Ansible/main/scripts/install.sh | bash
```

### With Custom Options

```bash
curl -fsSL https://raw.githubusercontent.com/bauer-group/IAS-Ansible/main/scripts/install.sh | \
  BRANCH=main SCHEDULE="*-*-* 02:00:00" bash
```

### Cloud-Init

Add to your cloud-init user-data:

```yaml
#cloud-config
runcmd:
  - curl -fsSL https://raw.githubusercontent.com/bauer-group/IAS-Ansible/main/scripts/install.sh | bash
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

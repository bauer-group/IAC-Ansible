# Automatic Updates

## Overview

The `auto_update` role configures automatic system updates with controlled reboot scheduling. All settings are centrally managed in this Git repository.

## Configuration

### Global Settings

Edit `inventory/production/group_vars/all/update_settings.yml`:

```yaml
# Update type: "all" or "security"
auto_update_type: "all"

# Update schedule (cron format): Daily at 02:00
auto_update_cron_minute: "0"
auto_update_cron_hour: "2"
auto_update_cron_day: "*"
auto_update_cron_month: "*"
auto_update_cron_weekday: "*"

# Reboot schedule (cron format): Sunday at 03:00
auto_update_reboot_enabled: true
auto_update_reboot_cron_minute: "0"
auto_update_reboot_cron_hour: "3"
auto_update_reboot_cron_day: "*"
auto_update_reboot_cron_month: "*"
auto_update_reboot_cron_weekday: "0"
```

### Per-Host Overrides

Create/edit `inventory/production/host_vars/<hostname>.yml`:

```yaml
# Only security updates for this host
auto_update_type: "security"

# Reboot on Saturday instead of Sunday
auto_update_reboot_cron_weekday: "6"
```

### Switching Between All Updates and Security-Only

**All updates** (default):
```yaml
auto_update_type: "all"
```

**Security updates only:**
```yaml
auto_update_type: "security"
```

On Ubuntu/Debian this controls:
- `all`: runs `apt-get upgrade` + `apt-get dist-upgrade`
- `security`: only applies updates from `-security` repository

On RedHat/CentOS:
- `all`: runs `dnf update`
- `security`: runs `dnf update --security`

## How It Works

### Update Flow

1. Cron fires at scheduled time (default: daily 02:00)
2. Update script runs (`/usr/local/sbin/auto-update.sh`)
3. Updates are applied (all or security-only)
4. If reboot is needed, flag is set
5. Reboot cron fires at scheduled time (default: Sunday 03:00)
6. If reboot flag exists, system reboots gracefully

### Files Deployed

| File | Purpose |
|------|---------|
| `/usr/local/sbin/auto-update.sh` | Update script |
| `/usr/local/sbin/auto-reboot.sh` | Reboot check script |
| `/etc/apt/apt.conf.d/50unattended-upgrades` | Ubuntu/Debian upgrade config |
| `/etc/apt/apt.conf.d/20auto-upgrades` | Ubuntu/Debian auto trigger |
| `/var/log/auto-update.log` | Update log |

### Cron Jobs

```
# Update: daily at 02:00
0 2 * * * /usr/local/sbin/auto-update.sh >> /var/log/auto-update.log 2>&1

# Reboot: Sunday at 03:00 (only if needed)
0 3 * * 0 /usr/local/sbin/auto-reboot.sh >> /var/log/auto-update.log 2>&1
```

## Schedule Examples

### Change Update to Weekly (Saturday 01:00)
```yaml
auto_update_cron_minute: "0"
auto_update_cron_hour: "1"
auto_update_cron_day: "*"
auto_update_cron_month: "*"
auto_update_cron_weekday: "6"
```

### Change Reboot to Monthly (1st Sunday at 04:00)
```yaml
auto_update_reboot_cron_minute: "0"
auto_update_reboot_cron_hour: "4"
auto_update_reboot_cron_day: "1-7"
auto_update_reboot_cron_month: "*"
auto_update_reboot_cron_weekday: "0"
```

### Disable Automatic Reboot
```yaml
auto_update_reboot_enabled: false
```

## Package Blacklisting

Exclude specific packages from updates:

```yaml
auto_update_blacklist:
  - docker-ce
  - docker-ce-cli
  - kubelet
  - kubeadm
```

## Monitoring

Check update logs:
```bash
ssh host "cat /var/log/auto-update.log"
ssh host "tail -f /var/log/auto-update.log"
```

Check if reboot is pending:
```bash
ssh host "test -f /var/run/reboot-required && echo 'Reboot needed' || echo 'OK'"
```

Check cron jobs:
```bash
ssh host "crontab -l | grep IAS"
```

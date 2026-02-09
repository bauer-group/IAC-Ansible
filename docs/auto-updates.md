# Automatic Updates

## Overview

The `auto_update` role manages automatic system updates via a **maintenance chain**: a single cron job that runs all steps sequentially.

```text
03:00 Maintenance Chain (daily, completes by ~03:30)
  ├── Phase 1: ansible-pull (sync config from Git)
  ├── Pre-Check: updates available?
  │     NO → exit (nothing to do)
  │     YES ↓
  ├── Status Monitor: open maintenance window (optional)
  ├── Phase 2: install updates
  ├── Phase 3: conditional reboot (weekday check + health checks)
  │     ├── Reboot → maintenance window closed after boot
  │     └── No reboot → maintenance window closed immediately
  └── Done
```

No race conditions, no lock files, guaranteed sequential execution.

## Configuration

### Global Settings

Edit `inventory/production/group_vars/all/update_settings.yml`:

```yaml
# Update type: "all" or "security"
auto_update_type: "all"

# Maintenance chain schedule (cron format): Daily at 03:00
auto_update_cron_minute: "0"
auto_update_cron_hour: "3"
auto_update_cron_day: "*"
auto_update_cron_month: "*"
auto_update_cron_weekday: "*"

# Reboot: only on Sunday (at the end of the chain, not a separate cron)
auto_update_reboot_enabled: true
auto_update_reboot_cron_weekday: "0"

# Include ansible-pull as Phase 1 of the chain
auto_update_chain_ansible_pull: true
```

### Per-Host Overrides

Create/edit `inventory/production/host_vars/<hostname>.yml`:

```yaml
# Only security updates for this host
auto_update_type: "security"

# Reboot on Saturday instead of Sunday
auto_update_reboot_cron_weekday: "6"
```

### Update Types

**All updates** (default):

```yaml
auto_update_type: "all"
```

**Security updates only:**

```yaml
auto_update_type: "security"
```

On Debian/Ubuntu:

- `all`: runs `apt-get upgrade` + `apt-get dist-upgrade`
- `security`: uses `unattended-upgrade` (only `-security` repository)

On RedHat/Rocky/Alma:

- `all`: runs `dnf update`
- `security`: runs `dnf update --security`

Existing configuration files are always preserved (`--force-confold`).

## Maintenance Chain

### Flow

1. Cron fires at scheduled time (default: daily 02:00)
2. Phase 1: `ansible-pull` syncs latest config from Git (optional)
3. Package lists are updated (`apt-get update` / `dnf check-update`)
4. If no updates available → exit early (no maintenance window opened)
5. If updates available → open status monitor maintenance window (optional)
6. Phase 2: Updates are installed
7. Phase 3: If reboot is needed AND today is the configured reboot day:
   - Pre-reboot health checks (dpkg/rpm audit, lock check, system load)
   - If all checks pass → `shutdown -r +1`
   - Maintenance window closed automatically after boot
8. If no reboot → maintenance window closed immediately

### Pre-Reboot Health Checks

Before any reboot, the script verifies:

| Check | Debian/Ubuntu | RedHat |
| --- | --- | --- |
| Package manager consistency | `dpkg --audit` | rpm lock check |
| No ongoing package operations | `fuser dpkg/lock-frontend` | `fuser rpm/.rpm.lock` |
| System load not critical | `loadavg < 3 * nproc` | `loadavg < 3 * nproc` |

If any check fails, the reboot is aborted and logged.

### Files Deployed

| File | Purpose |
| --- | --- |
| `/usr/local/sbin/auto-update.sh` | Maintenance chain script |
| `/etc/apt/apt.conf.d/50unattended-upgrades` | Debian/Ubuntu upgrade config |
| `/etc/apt/apt.conf.d/20auto-upgrades` | Debian/Ubuntu auto trigger |
| `/var/log/auto-update.log` | Maintenance chain log |

### Cron Job

```text
# Maintenance chain: daily at 03:00
0 3 * * * /usr/local/sbin/auto-update.sh >> /var/log/auto-update.log 2>&1
```

## Status Monitor Integration

Automatic maintenance window management for status monitoring tools like Uptime Kuma. Opens a window before updates and closes it after, preventing false alerts.

### Architecture

```text
/etc/iac-ansible/
  status-monitor.env              ← Credentials (mode 0600, NOT in Git)
  status-monitor.env.example      ← Template with instructions

/usr/local/sbin/
  iac-status-monitor.sh           ← Generic wrapper (provider-agnostic)

/usr/local/lib/iac-ansible/
  providers/
    uptime-kuma.py                ← Uptime Kuma provider (replaceable)

/opt/iac-ansible/
  statusmon-venv/                 ← Isolated Python venv for provider deps

/var/lib/iac-ansible/
  maintenance-state               ← Persistent state (survives reboot)
```

### Setup

#### Step 1: Enable in Ansible

In `inventory/production/group_vars/all/update_settings.yml`:

```yaml
auto_update_statusmon_enabled: true
auto_update_statusmon_provider: "uptime-kuma"
```

#### Step 2: Configure Credentials

##### Option A: Via Ansible Vault (recommended for fleet management)

```bash
# Encrypt the password
ansible-vault encrypt_string 'your-password' --name 'vault_statusmon_password'
```

Add to `inventory/production/group_vars/all/update_settings.yml`:

```yaml
auto_update_statusmon_url: "https://status.bauer-group.com"
auto_update_statusmon_username: "iac-ansible"
auto_update_statusmon_password: "{{ vault_statusmon_password }}"
```

The `.env` file is deployed automatically to each host.

##### Option B: Manual .env per host

Leave `auto_update_statusmon_url`, `auto_update_statusmon_username`, and `auto_update_statusmon_password` empty. Then on each host:

```bash
cp /etc/iac-ansible/status-monitor.env.example /etc/iac-ansible/status-monitor.env
vim /etc/iac-ansible/status-monitor.env    # set URL, username, password
chmod 600 /etc/iac-ansible/status-monitor.env
```

#### Step 3: Authentication

Uptime Kuma uses a single admin account. The Socket.IO API requires these admin credentials (username/password) for maintenance window management.

Use the Uptime Kuma admin credentials in the `.env` file. The password should always be stored encrypted via Ansible Vault.

### Monitor Discovery

Monitors are found **automatically by FQDN hostname**. No manual ID mapping needed.

The provider searches all monitors in Uptime Kuma and matches against:

- Monitor **name** (e.g., `0046-20.cloud.bauer-group.com HTTP`)
- Monitor **URL** (e.g., `https://0046-20.cloud.bauer-group.com`)
- Monitor **hostname** field (e.g., `0046-20.cloud.bauer-group.com`)

Both the FQDN and short hostname are checked. If no matching monitor is found, the maintenance window step is silently skipped.

To override the hostname used for discovery, add to the `.env` file:

```bash
STATUS_MONITOR_HOSTNAME="custom-name.example.com"
```

### Graceful Behavior

| Situation | Behavior |
| --- | --- |
| No `.env` file | Skipped silently |
| URL or credentials empty | Skipped silently |
| Status monitor unreachable | Warning logged, updates proceed |
| Server not found in monitors | Skipped silently |
| No provider script found | Skipped silently |
| No updates available | No maintenance window opened |

Updates are **never blocked** by status monitor issues.

### Post-Reboot

If a reboot is initiated, the maintenance window stays open. A systemd oneshot service (`iac-maintenance-close.service`) runs after boot and closes the window automatically.

```bash
# Check if post-reboot service is enabled
systemctl is-enabled iac-maintenance-close.service

# Check if a maintenance window is still open
cat /var/lib/iac-ansible/maintenance-state

# Manually close a stuck maintenance window
/usr/local/sbin/iac-status-monitor.sh stop
```

### Adding a New Provider

1. Create a Python script: `roles/auto_update/files/providers/my-provider.py`
1. The script must:
   - Read `STATUS_MONITOR_URL`, `STATUS_MONITOR_USERNAME`, `STATUS_MONITOR_PASSWORD`, `STATUS_MONITOR_HOSTNAME`, `STATUS_MONITOR_STATE_FILE` from environment
   - Accept `start` or `stop` as first argument
   - Write the maintenance ID to `STATUS_MONITOR_STATE_FILE` on `start`
   - Delete `STATUS_MONITOR_STATE_FILE` on `stop`
   - Exit 0 on success, non-zero on failure
1. Set the provider: `auto_update_statusmon_provider: "my-provider"`
1. If the provider needs Python packages, add an install task to `roles/auto_update/tasks/main.yml`.

## Schedule Examples

### Change Update to Weekly (Saturday 01:00)

```yaml
auto_update_cron_minute: "0"
auto_update_cron_hour: "1"
auto_update_cron_weekday: "6"
```

### Reboot Every Day (if needed)

```yaml
auto_update_reboot_cron_weekday: "*"
```

### Disable Automatic Reboot

```yaml
auto_update_reboot_enabled: false
```

### Disable ansible-pull in Chain

```yaml
auto_update_chain_ansible_pull: false
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

Check maintenance chain logs:

```bash
tail -f /var/log/auto-update.log
```

Check if reboot is pending:

```bash
# Debian/Ubuntu
test -f /var/run/reboot-required && echo 'Reboot needed' || echo 'OK'

# RedHat
needs-restarting -r
```

Check cron jobs:

```bash
crontab -l | grep IAC
```

Check status monitor state:

```bash
# Is a maintenance window currently open?
cat /var/lib/iac-ansible/maintenance-state 2>/dev/null || echo "No active window"

# Manually test the status monitor integration
/usr/local/sbin/iac-status-monitor.sh start
/usr/local/sbin/iac-status-monitor.sh stop
```

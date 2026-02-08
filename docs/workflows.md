# Workflows

## Available Make Commands

| Command | Description |
|---------|-------------|
| `make deploy` | Full deployment (site.yml) |
| `make update` | System updates only |
| `make reboot` | Controlled reboot |
| `make cleanup` | System cleanup |
| `make ping` | Ping all hosts |
| `make facts` | Gather host facts |
| `make check` | Dry-run deployment |
| `make push` | Trigger immediate pull on hosts |
| `make lint` | Lint playbooks and roles |
| `make setup` | Install Galaxy requirements |

## Common Workflows

### Deploy Configuration Changes

```bash
# 1. Edit configuration
vim inventory/production/group_vars/all/update_settings.yml

# 2. Test with dry-run
make check LIMIT=0046-20.cloud.bauer-group.com

# 3. Apply to single host
make deploy LIMIT=0046-20.cloud.bauer-group.com

# 4. Apply to all hosts
make deploy

# 5. Commit and push (for automated pull)
git add -A && git commit -m "Update settings" && git push
```

### Change Update Schedule

```bash
# Edit update_settings.yml
# Change auto_update_cron_* and auto_update_reboot_cron_* values
# Commit and push
# Servers will apply new schedule on next pull
```

### Emergency: Disable Updates on a Host

```bash
# Quick: via extra vars
ansible-playbook -i inventory/production/hosts.yml playbooks/site.yml \
  --limit "problem-host" -e "auto_update_enabled=false"

# Permanent: add to host_vars
echo "auto_update_enabled: false" >> inventory/production/host_vars/problem-host.yml
git add . && git commit -m "Disable auto-update on problem-host" && git push
```

### Bootstrap New Server

```bash
# Option A: One-line installer (run ON the server)
curl -fsSL https://raw.githubusercontent.com/bauer-group/IAS-Ansible/main/scripts/install.sh | bash

# Option B: Push setup from control machine
ansible-playbook -i inventory/production/hosts.yml playbooks/setup.yml \
  --limit "new-server.example.com"
```

### Force Immediate Update

```bash
# Via push script
make push LIMIT=0046-20.cloud.bauer-group.com

# Or SSH directly
ssh root@0046-20.cloud.bauer-group.com "systemctl start ansible-pull.service"
```

### Rolling Reboot

```bash
# Reboot hosts one by one (serial: 1 is default in reboot playbook)
make reboot LIMIT=auto_update
```

## Day-to-Day Operations

### Check Host Status
```bash
make ping                                    # All hosts
make ping LIMIT="*.bauer-group.com"          # Pattern
```

### View Host Facts
```bash
make facts LIMIT=0046-20.cloud.bauer-group.com
```

### Run Ad-Hoc Commands
```bash
# Check uptime
ansible -i inventory/production/hosts.yml all -m command -a "uptime"

# Check disk space
ansible -i inventory/production/hosts.yml all -m command -a "df -h /"

# Check pending updates (Debian)
ansible -i inventory/production/hosts.yml ubuntu -m command -a "apt list --upgradable"
```

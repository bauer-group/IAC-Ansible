# Inventory Management

## Adding a New Host

### 1. Add to inventory

Edit `inventory/production/hosts.yml`:

```yaml
    auto_update:
      hosts:
        new-server.example.com:
          ansible_host: new-server.example.com
          platform: ubuntu_2404
          labels:
            - production
```

### 2. Create host vars (optional)

Create `inventory/production/host_vars/new-server.example.com.yml`:

```yaml
---
platform: ubuntu_2404
auto_update_type: "security"

# Host-specific services
services:
  - nginx
  - docker
```

### 3. Add to relevant groups

```yaml
    webservers:
      hosts:
        new-server.example.com: {}

    label_production:
      hosts:
        new-server.example.com: {}
```

### 4. Commit and push

```bash
git add inventory/
git commit -m "Add new-server.example.com to inventory"
git push
```

## Removing a Host

1. Remove from all groups in `hosts.yml`
2. Delete `host_vars/<hostname>.yml`
3. Commit and push
4. On the host: `systemctl disable --now ansible-pull.timer`

## Group Structure

### Platform Groups

Auto-assigned based on detected OS. Used for conditional task execution:

```yaml
ubuntu:          # All Ubuntu hosts
  ubuntu_2404:   # Ubuntu 24.04 specifically
  ubuntu_2204:   # Ubuntu 22.04
debian:          # All Debian hosts
centos:          # All CentOS hosts
redhat:          # All RHEL hosts
```

### Functional Groups

Determine which roles are applied:

```yaml
auto_update:     # Receives auto_update role
webservers:      # Web server configuration
databases:       # Database server configuration
docker_hosts:    # Docker host configuration
monitoring:      # Monitoring agents
```

### Label Groups

For flexible filtering:

```yaml
label_cloud:       # Cloud-hosted servers
label_production:  # Production environment
label_staging:     # Staging environment
label_bauer_group: # BAUER GROUP owned
```

## Variable Precedence

From lowest to highest priority:

1. `roles/*/defaults/main.yml` - Role defaults
2. `inventory/production/group_vars/all/main.yml` - Global vars
3. `inventory/production/group_vars/all/update_settings.yml` - Update settings
4. `inventory/production/host_vars/<hostname>.yml` - Host-specific
5. `--extra-vars` / `-e` - Command-line overrides

## Multiple Environments

```bash
make deploy                    # Uses production (default)
make deploy ENV=staging        # Uses staging
make deploy ENV=production     # Explicit production
```

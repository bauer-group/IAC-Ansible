# Host Filtering Guide

IAC-Ansible supports multiple filtering methods to target specific servers.

## Ansible Native Patterns (`--limit`)

### Exact Hostname
```bash
make deploy LIMIT=0046-20.cloud.bauer-group.com
```

### Wildcard Patterns
```bash
make deploy LIMIT="*.bauer-group.com"           # All bauer-group hosts
make deploy LIMIT="0046-*"                      # All hosts starting with 0046
make deploy LIMIT="*.cloud.*"                   # All cloud hosts
```

### IP Address Patterns
```bash
make deploy LIMIT="192.168.1.*"                 # Subnet
make deploy LIMIT="10.0.0.1"                    # Exact IP
```

### Group-Based
```bash
make deploy LIMIT=auto_update                   # All auto-update hosts
make deploy LIMIT=ubuntu                        # All Ubuntu hosts
make deploy LIMIT=webservers                    # All web servers
```

### Set Operations
```bash
# AND (intersection) - hosts in BOTH groups
make deploy LIMIT="auto_update:&ubuntu"

# NOT (exclusion) - auto_update hosts EXCEPT webservers
make deploy LIMIT="auto_update:!webservers"

# Multiple hosts (comma-separated)
make deploy LIMIT="host1.example.com,host2.example.com"
```

## Label Filtering

Hosts can have labels defined in their inventory entry:

```yaml
# inventory/production/hosts.yml
0046-20.cloud.bauer-group.com:
  labels:
    - cloud
    - production
    - bauer-group
```

Filter by label:
```bash
make deploy LABEL=cloud
make deploy LABEL=production
```

## Service Filtering

If hosts define `services` in their host_vars:

```yaml
# inventory/production/host_vars/myhost.yml
services:
  - nginx
  - docker
  - postgresql
```

Filter by service:
```bash
make deploy SERVICE=nginx
make deploy SERVICE=docker
```

## Tag-Based Filtering

Run only specific parts of the playbook:

```bash
make deploy TAGS=common                         # Only common tasks
make deploy TAGS=update                         # Only update tasks
make deploy TAGS=ansible-pull                   # Only pull setup
make deploy TAGS="common,update"                # Multiple tags
```

## Custom Filter Plugins

Available in playbooks and templates:

```yaml
# Filter hosts by label
{{ groups['all'] | filter_by_label('production', hostvars) }}

# Check hostname pattern
when: inventory_hostname | matches_pattern('*.bauer-group.com')

# Check hostname regex
when: inventory_hostname | matches_regex('^web-\d+\.example\.com$')

# Filter by platform
{{ groups['all'] | filter_by_platform('ubuntu_2404', hostvars) }}

# Check for service
when: services | default([]) | has_service('nginx')
```

## Combined Filtering Examples

```bash
# Ubuntu hosts with auto-update, only update tasks
make update LIMIT="auto_update:&ubuntu" TAGS=update

# All bauer-group hosts, labeled as cloud
make deploy LIMIT="*.bauer-group.com" LABEL=cloud

# Specific host, dry-run
make check LIMIT=0046-20.cloud.bauer-group.com
```

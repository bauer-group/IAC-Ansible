# Server Naming & Coding Scheme

## Schema

```
AAAA-GG.cloud.bauer-group.com
```

| Part | Format | Description |
| --- | --- | --- |
| **AAAA** | 4-digit numeric, zero-padded | Asset ID - unique across all infrastructure |
| **GG** | 2-digit numeric | Group number - resource role/type |
| **cloud.bauer-group.com** | constant | Domain suffix |

**Example:** `0046-20.cloud.bauer-group.com` = Asset 0046, Public Cloud VM

## Group Numbers

### 00-09: Physical Hardware

| Code | Type |
| --- | --- |
| 00 | Physical server |
| 05 | Physical cluster node |

### 10-19: Virtual Machines

| Code | Type |
| --- | --- |
| 10 | VM Private Cloud |
| 15 | VM Cluster (Proxmox, VMware) |

### 20-29: Public Cloud Instances

| Code | Type |
| --- | --- |
| 20 | VM / Compute instance (Public Cloud) |
| 25 | Public Cloud managed service |

### 30-39: Cloud Services

| Code | Type |
| --- | --- |
| 30 | Cloud service on physical server |
| 35 | Cloud service on virtual machine |

### 40-49: Network, Storage, Security

| Code | Type |
| --- | --- |
| 40 | Network device (router, switch) |
| 45 | Storage (NAS, SAN, Ceph) |
| 48 | Security / Firewall |

### 50-59: Production Environments

| Code | Type |
| --- | --- |
| 50 | Production environment (external) |
| 55 | Production environment (internal) |

### 60-69: Development & Test Environments

| Code | Type |
| --- | --- |
| 60 | Development |
| 61 | Staging |
| 68 | Test / Sandbox |

### 70-79: Operations Management

| Code | Type |
| --- | --- |
| 70 | Monitoring |
| 71 | Logging |
| 72 | Backup |
| 78 | Management tooling |

### 80-89: IoT and Edge

| Code | Type |
| --- | --- |
| 80 | IoT gateway |
| 85 | IoT node |
| 88 | Edge device |

### 90-99: Reserved

Reserved for future extensions.

## Examples

| Resource | Hostname |
| --- | --- |
| Physical server | `0001-00.cloud.bauer-group.com` |
| Virtual machine | `0020-10.cloud.bauer-group.com` |
| Cluster VM | `0033-15.cloud.bauer-group.com` |
| Public Cloud instance | `0046-20.cloud.bauer-group.com` |
| Cloud service on physical | `0001-30.cloud.bauer-group.com` |
| Cloud service on VM | `0020-35.cloud.bauer-group.com` |
| Storage system | `0100-45.cloud.bauer-group.com` |
| Production external | `2001-50.cloud.bauer-group.com` |
| Production internal | `2002-55.cloud.bauer-group.com` |
| Development | `0500-60.cloud.bauer-group.com` |
| Staging | `0501-61.cloud.bauer-group.com` |
| Monitoring | `0300-70.cloud.bauer-group.com` |
| IoT gateway | `9001-80.cloud.bauer-group.com` |

## Ansible Integration

### Automatic Hostname Decoding

The filter plugin `parse_asset_hostname` extracts metadata from any hostname:

```yaml
# In playbooks/templates
{{ inventory_hostname | parse_asset_hostname }}
# Returns: {"asset_id": "0046", "group_code": "20", "asset_type": "public_cloud_vm", "valid": true}

# Individual fields
{{ inventory_hostname | asset_id }}        # "0046"
{{ inventory_hostname | group_code }}      # "20"
{{ inventory_hostname | asset_type }}      # "public_cloud_vm"
```

### Filtering by Asset Type

```bash
# All public cloud VMs (group 20-29)
make deploy LIMIT="*-2?.cloud.bauer-group.com"

# All physical servers (group 00)
make deploy LIMIT="*-00.cloud.bauer-group.com"

# All monitoring hosts (group 70)
make deploy LIMIT="*-70.cloud.bauer-group.com"

# Specific asset across all roles
make deploy LIMIT="0046-*.cloud.bauer-group.com"

# Using inventory groups
make deploy LIMIT=public_cloud
make deploy LIMIT=physical_servers
```

### Inventory Groups

Hosts are automatically assigned to asset type groups based on their group code:

```yaml
physical_servers:     # 00-09
virtual_machines:     # 10-19
public_cloud:         # 20-29
cloud_services:       # 30-39
network_storage:      # 40-49
production:           # 50-59
dev_test:             # 60-69
operations:           # 70-79
iot_edge:             # 80-89
```

## Rules

- The **Asset ID** uniquely identifies an asset
- The **Group number** classifies the role/function
- If a resource changes role, **only the group number changes**, not the Asset ID
- An asset can have **multiple group assignments** under the same Asset ID
- The **domain is constant** (`cloud.bauer-group.com`)
- The scheme is fully **numeric, machine-readable, and semantically stable**
- The **hyphen separates identity (asset) from function (group)**

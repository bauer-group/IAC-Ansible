# Cloud-Init Integration

## Minimal Cloud-Init User Data

```yaml
#cloud-config
runcmd:
  - curl -fsSL https://raw.githubusercontent.com/bauer-group/IAC-Ansible/main/scripts/install.sh | bash
```

## Full Cloud-Init User Data

```yaml
#cloud-config

# Set timezone
timezone: Etc/UTC

# Ensure prerequisites
packages:
  - curl
  - git

# Bootstrap IAC-Ansible
runcmd:
  - |
    curl -fsSL https://raw.githubusercontent.com/bauer-group/IAC-Ansible/main/scripts/install.sh | \
      BRANCH=main \
      SCHEDULE="*-*-* 02:00:00" \
      bash

# Optional: Write custom host vars before first pull
write_files:
  - path: /etc/ias-ansible-labels
    content: |
      cloud
      production
    permissions: '0644'
```

## Terraform Integration

```hcl
resource "hcloud_server" "web" {
  name        = "0046-20"
  server_type = "cx21"
  image       = "ubuntu-24.04"

  user_data = <<-EOF
    #cloud-config
    runcmd:
      - curl -fsSL https://raw.githubusercontent.com/bauer-group/IAC-Ansible/main/scripts/install.sh | bash
  EOF
}
```

## Hetzner Cloud

```bash
hcloud server create \
  --name 0046-20 \
  --type cx21 \
  --image ubuntu-24.04 \
  --user-data-from-file cloud-init.yml
```

## AWS EC2

```bash
aws ec2 run-instances \
  --image-id ami-xxxxx \
  --instance-type t3.micro \
  --user-data file://cloud-init.yml
```

## After Provisioning

1. The installer runs automatically on first boot
2. Ansible is installed
3. `ansible-pull` is configured with systemd timer
4. Initial pull runs and applies the configuration
5. Add the new host to `inventory/production/hosts.yml`
6. Commit and push - server will pick up group assignments on next pull

# SSH Hardening

## Overview

Optional SSH hardening with automatic key deployment. Disabled by default - must be explicitly enabled per host.

**Safety:** The role REFUSES to harden SSH if no keys are deployed. It is impossible to lock yourself out.

```text
common_ssh_hardening: true
        │
        ▼
┌─ Fetch GitHub keys (github.com/<user>.keys)
│  + Vault extra keys (common_ssh_extra_keys)
│
├─ No keys found? ──► ABORT (play fails with clear message)
│
├─ Deploy authorized_keys
│
├─ Verify keys present? ──► 0 keys? ──► ABORT
│
├─ Validate sshd config (sshd -t)
│
└─ Apply hardening + restart sshd
```

## Quick Start

### 1. Configure key sources globally

In `inventory/production/group_vars/all/main.yml`:

```yaml
common_ssh_github_users:
  - karl-bauer
  - ops-colleague
```

Keys are fetched live from `https://github.com/<username>.keys` on every run. When a user rotates their key on GitHub, it updates automatically on the next run.

### 2. Enable hardening per host

In `inventory/production/host_vars/<hostname>.yml`:

```yaml
common_ssh_hardening: true
```

### 3. Run Ansible

```bash
ansible-playbook playbooks/site.yml --limit <hostname>
```

The play will:

1. Fetch keys from GitHub for all configured users
1. Deploy them to `/root/.ssh/authorized_keys`
1. Verify the keys are present
1. Harden sshd (disable password auth, restrict root login)

## Key Sources

### GitHub Profiles

```yaml
common_ssh_github_users:
  - karl-bauer           # fetches github.com/karl-bauer.keys
  - ops-team-member      # fetches github.com/ops-team-member.keys
```

How it works:

- GitHub exposes public SSH keys at `https://github.com/<username>.keys`
- Keys are fetched on every Ansible run (always up to date)
- If a GitHub user is not reachable (timeout, 404), that user is skipped
- If ALL sources return zero keys, the play aborts

### Vault Extra Keys

For users without GitHub or for service accounts (deploy bots, CI/CD):

```bash
# Encrypt a public key
ansible-vault encrypt_string 'ssh-ed25519 AAAA... deploy-bot@ci' --name 'vault_ssh_key_deploy_bot'
```

Add to vault file or group_vars:

```yaml
common_ssh_extra_keys:
  - "{{ vault_ssh_key_deploy_bot }}"
```

### Combined Example

```yaml
# group_vars/all/main.yml (global key sources)
common_ssh_github_users:
  - karl-bauer
  - ops-colleague
common_ssh_extra_keys:
  - "{{ vault_ssh_key_deploy_bot }}"

# host_vars/webserver01.yml (enable hardening for this host)
common_ssh_hardening: true

# host_vars/devbox.yml (keys deployed but no hardening)
common_ssh_hardening: false
```

In this example, `webserver01` gets keys AND hardening, while `devbox` gets keys deployed but password auth remains enabled.

## What Gets Hardened

| Setting | Value | Effect |
| --- | --- | --- |
| `PermitRootLogin` | `prohibit-password` | Root login only via SSH key |
| `PasswordAuthentication` | `no` | No password login for any user |

Override defaults per host:

```yaml
# host_vars/special-server.yml
common_ssh_hardening: true
common_ssh_permit_root_login: "no"              # completely disable root login
common_ssh_password_authentication: "no"         # default
common_ssh_authorized_keys_user: "deploy"        # deploy keys for 'deploy' instead of 'root'
```

## Config Deployment

The role detects the sshd config method automatically:

- **Modern systems** (Ubuntu 22.04+, Debian 12+, RHEL 9+): drop-in file `/etc/ssh/sshd_config.d/99-iac-hardening.conf`
- **Legacy systems**: inline edit of `/etc/ssh/sshd_config` via `lineinfile`

Both methods validate the config with `sshd -t` before writing.

## Safety Mechanisms

| Protection | How |
| --- | --- |
| Default OFF | `common_ssh_hardening: false` in defaults |
| No global override | Must be enabled per host in `host_vars/` |
| Key check before hardening | Play aborts if zero keys deployed |
| Double verification | Keys are checked after writing `authorized_keys` |
| Config validation | `sshd -t` runs before any config change |
| No secrets in public repo | GitHub usernames are public, vault keys encrypted |
| Automatic key rotation | GitHub keys fetched live on every run |

## Troubleshooting

### Check deployed keys

```bash
cat /root/.ssh/authorized_keys
```

### Check sshd config

```bash
# Modern systems
cat /etc/ssh/sshd_config.d/99-iac-hardening.conf

# Validate
sshd -t
```

### Test key login before enabling hardening

```bash
# Deploy keys first (without hardening)
ansible-playbook playbooks/site.yml --limit server01

# Test SSH key login manually
ssh -i ~/.ssh/id_ed25519 root@server01

# If it works, enable hardening
# host_vars/server01.yml: common_ssh_hardening: true
ansible-playbook playbooks/site.yml --limit server01
```

### Emergency: locked out

If you somehow get locked out (should not be possible with the safety checks):

1. Access via cloud provider console (Hetzner, AWS, etc.)
1. Edit `/etc/ssh/sshd_config.d/99-iac-hardening.conf` or `/etc/ssh/sshd_config`
1. Set `PasswordAuthentication yes`
1. Run `systemctl restart sshd`

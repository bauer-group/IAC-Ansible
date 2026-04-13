# Host Onboarding

Schritt-für-Schritt-Anleitung für neue Hosts.

## 1. Hostname festlegen

Format: `AAAA-GG.cloud.bauer-group.com`

- **AAAA**: 4-stellige Asset-ID (z.B. `0048`)
- **GG**: 2-stelliger Group-Code (siehe [Server Naming](server-naming.md))

## 2. host_vars erstellen

```yaml
# inventory/production/host_vars/<hostname>.yml
---
platform: ubuntu_2404

asset_id: "0048"
group_code: "20"
asset_type: docker_host

labels:
  - production
  - public-cloud
  - ubuntu
  - docker-host
```

## 3. Host in Inventory aufnehmen

In `inventory/production/hosts.yml` den Host den passenden Gruppen zuordnen:

```yaml
docker_hosts:
  hosts:
    0048-20.cloud.bauer-group.com:

auto_update:
  hosts:
    0048-20.cloud.bauer-group.com:
```

## 4. Vault-Credentials vorbereiten (optional)

Nur nötig wenn Secrets genutzt werden (siehe [Vault-Doku](vault.md)).

**Ansible Vault:**

```bash
# Vault-Passwort auf Host deployen
printf '%s' "passwort" > /etc/ansible/vault-password
chmod 0400 /etc/ansible/vault-password
```

**HashiCorp Vault:**

```bash
# AppRole-Credentials auf Host deployen
mkdir -p /etc/iac-ansible
printf '%s' "<role-id>" > /etc/iac-ansible/vault-role-id
printf '%s' "<secret-id>" > /etc/iac-ansible/vault-secret-id
chmod 0400 /etc/iac-ansible/vault-role-id /etc/iac-ansible/vault-secret-id
```

## 5. Bootstrap

```bash
curl -fsSL https://raw.githubusercontent.com/bauer-group/IAC-Ansible/main/scripts/install.sh | \
  IAC_HOSTNAME=0048-20.cloud.bauer-group.com \
  VAULT_PASSWORD="optional-vault-passwort" \
  bash
```

Oder mit Staging-Inventory:

```bash
curl -fsSL https://raw.githubusercontent.com/bauer-group/IAC-Ansible/main/scripts/install.sh | \
  IAC_HOSTNAME=0048-20.cloud.bauer-group.com \
  INVENTORY="inventory/staging/hosts.yml" \
  BRANCH="staging" \
  bash
```

## 6. Verifizieren

```bash
# Auf der lokalen Maschine
make ping LIMIT=0048-20.cloud.bauer-group.com
make deploy LIMIT=0048-20.cloud.bauer-group.com

# Auf dem Host selbst
systemctl status ansible-pull.timer
tail -20 /var/log/ansible/ansible-pull.log
```

## Checkliste

- [ ] Hostname folgt AAAA-GG Schema
- [ ] host_vars Datei erstellt
- [ ] Host in hosts.yml den richtigen Gruppen zugeordnet
- [ ] Vault-Credentials deployt (falls benötigt)
- [ ] Bootstrap via install.sh ausgeführt
- [ ] `make ping` erfolgreich
- [ ] ansible-pull Timer aktiv

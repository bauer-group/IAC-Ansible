# Ansible Vault - Secrets Management

## Überblick

Ansible Vault verschlüsselt sensible Daten (Passwörter, API-Keys, SSH-Keys) mit AES-256. Die verschlüsselten Dateien werden im Git-Repo gespeichert, sind aber nur mit dem Vault-Passwort lesbar.

```
group_vars/all/
├── main.yml              ← Klartext (allgemeine Variablen)
├── update_settings.yml   ← Klartext (Update-Konfiguration)
└── secrets.yml           ← Verschlüsselt (Passwörter, Keys)
```

## Einrichtung

### 1. Vault erstellen

```bash
# Production
make vault-create

# Staging
make vault-create ENV=staging
```

Dies öffnet einen Editor. Beispielinhalt:

```yaml
---
# IAC-Ansible Vault Secrets
# Bearbeiten mit: make vault-edit

# Mail relay (msmtp)
vault_msmtp_password: "dein-smtp-passwort"

# SSH deploy key (optional)
vault_ssh_key_deploy_bot: "ssh-ed25519 AAAA..."

# Status monitor credentials (optional)
vault_statusmon_url: "https://status.example.com"
vault_statusmon_username: "admin"
vault_statusmon_password: "geheim"
```

### 2. Secrets referenzieren

In `group_vars/all/main.yml` (Klartext):

```yaml
# Mail relay - Passwort aus Vault
common_msmtp_password: "{{ vault_msmtp_password }}"

# SSH deploy key aus Vault
common_ssh_extra_keys:
  - "{{ vault_ssh_key_deploy_bot }}"
```

**Konvention:** Vault-Variablen beginnen immer mit `vault_`, damit klar ist woher der Wert kommt.

### 3. Vault-Passwort für ansible-pull

Damit Server den Vault entschlüsseln können, muss das Passwort auf jedem Server hinterlegt werden:

```bash
# Auf dem Server als root:
mkdir -p /etc/ansible
echo "dein-vault-passwort" > /etc/ansible/vault-password
chmod 600 /etc/ansible/vault-password
```

In `ansible.cfg` ist die Datei bereits referenzierbar:

```ini
[defaults]
vault_password_file = /etc/ansible/vault-password
```

**Alternativ:** Das Vault-Passwort kann auch über die Umgebungsvariable `ANSIBLE_VAULT_PASSWORD_FILE` gesetzt werden.

## Tägliche Nutzung

### Secrets bearbeiten

```bash
make vault-edit              # Production
make vault-edit ENV=staging  # Staging
```

### Secrets anzeigen (temporär entschlüsseln)

```bash
ansible-vault view inventory/production/group_vars/all/secrets.yml
```

### Einzelnen Wert verschlüsseln

Für Inline-Verschlüsselung in Klartext-Dateien:

```bash
ansible-vault encrypt_string 'mein-geheimes-passwort' --name 'vault_msmtp_password'
```

Ausgabe direkt in YAML einfügbar:

```yaml
vault_msmtp_password: !vault |
  $ANSIBLE_VAULT;1.1;AES256
  6162636465...
```

### Vault-Passwort ändern

```bash
ansible-vault rekey inventory/production/group_vars/all/secrets.yml
```

## Welche Secrets gehören in den Vault?

| Secret | Variable | Verwendet von |
|--------|----------|---------------|
| SMTP-Passwort | `vault_msmtp_password` | common (msmtp) |
| SSH Deploy Keys | `vault_ssh_key_deploy_bot` | common (SSH hardening) |
| Status Monitor URL | `vault_statusmon_url` | auto_update |
| Status Monitor User | `vault_statusmon_username` | auto_update |
| Status Monitor Passwort | `vault_statusmon_password` | auto_update |

## Was passiert ohne Vault?

- **Keine `secrets.yml` vorhanden:** Alles funktioniert. Features die Vault-Variablen brauchen (msmtp, Status Monitor) werden übersprungen.
- **`secrets.yml` vorhanden, kein Passwort:** `ansible-pull` schlägt fehl. Daher den Vault erst erstellen wenn das Passwort auf allen Servern hinterlegt ist.

## Sicherheitshinweise

- Vault-Passwort **niemals** ins Git-Repo committen
- `.gitignore` enthält bereits Muster für Passwort-Dateien
- Vault-Passwort über sicheren Kanal an Server verteilen (z.B. SSH, Cloud-Init Secrets)
- Regelmäßig rotieren mit `ansible-vault rekey`
- In CI/CD als Secret-Variable hinterlegen (`ANSIBLE_VAULT_PASSWORD`)

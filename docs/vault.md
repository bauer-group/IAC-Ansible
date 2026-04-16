# Secrets Management

## Überblick

Das IAC-Ansible-Repo unterstützt drei Betriebsmodi für Secrets:

| Modus               | `secrets_backend`   | Beschreibung                                  | Host-Voraussetzungen     |
|----------------------|---------------------|-----------------------------------------------|--------------------------|
| **Kein Vault**       | `"ansible-vault"`   | Keine Secrets — alle Features laufen ohne     | Keine                    |
| **Ansible Vault**    | `"ansible-vault"`   | Datei-Verschlüsselung (AES-256), out-of-band | `secrets.yml` + Passwort |
| **HashiCorp Vault**  | `"hashicorp-vault"` | Zentraler Secret-Store mit API, KV v2         | AppRole-Credentials      |

**Standard:** `secrets_backend: "ansible-vault"` — das Repo funktioniert sofort ohne
jede Konfiguration, weil alle Secret-abhängigen Features graceful degradieren.

### Architektur

Die **`secrets` Role** läuft als Phase 0 in `site.yml`, bevor alle anderen Roles:

```
site.yml
  │
  ├─ Phase 0: secrets Role
  │    │
  │    ├─ secrets_backend == "ansible-vault"
  │    │    └─ secrets.yml vorhanden? → secrets_* Variablen geladen
  │    │       secrets.yml fehlt?     → secrets_* bleiben leer (OK)
  │    │
  │    └─ secrets_backend == "hashicorp-vault"
  │         └─ KV v2 API → secrets_* Variablen aus Vault-Server
  │
  ├─ Phase 1: common        (Defaults pullen aus secrets_*)
  ├─ Phase 2: ansible_pull
  ├─ Phase 3: auto_update   (Defaults pullen aus secrets_*)
  └─ Phase 4-6: ...
```

Die Consumer-Rollen referenzieren `secrets_*` direkt in ihren Defaults:

```yaml
# roles/common/defaults/main.yml
common_msmtp_password: "{{ secrets_msmtp_password | default('') }}"
common_ssh_extra_keys: >-
  {{ [secrets_ssh_deploy_key]
     if (secrets_ssh_deploy_key | default('') | length > 0) else [] }}

# roles/auto_update/defaults/main.yml
auto_update_statusmon_url: "{{ secrets_statusmon_url | default('') }}"
auto_update_statusmon_username: "{{ secrets_statusmon_username | default('') }}"
auto_update_statusmon_password: "{{ secrets_statusmon_password | default('') }}"
```

Kein Mapping-Layer, keine `set_fact`-Shim — idiomatisches Ansible-
Defaults-Precedence.

### Dateistruktur

```
group_vars/all/
├── main.yml              ← Klartext (allgemeine Variablen)
├── update_settings.yml   ← Klartext (Update-Konfiguration)
├── secrets_config.yml    ← Backend-Toggle + HashiCorp Vault Settings
└── secrets.yml           ← Verschlüsselt (nur bei Ansible Vault, out-of-band)
```

### Secrets-Variablen

| Secret                  | Secrets-Variable              | Consumer-Variable                | Verwendet von          |
|-------------------------|-------------------------------|----------------------------------|------------------------|
| SMTP-Passwort           | `secrets_msmtp_password`      | `common_msmtp_password`          | common (msmtp)         |
| SSH Deploy Key          | `secrets_ssh_deploy_key`      | `common_ssh_extra_keys`          | common (SSH hardening) |
| Status Monitor URL      | `secrets_statusmon_url`       | `auto_update_statusmon_url`      | auto_update            |
| Status Monitor User     | `secrets_statusmon_username`  | `auto_update_statusmon_username` | auto_update            |
| Status Monitor Passwort | `secrets_statusmon_password`  | `auto_update_statusmon_password` | auto_update            |

**Konvention:** Alle von der secrets-Rolle veröffentlichten Variablen
beginnen mit `secrets_` (Role-Prefix). Consumer-Rollen pullen sie in
ihren eigenen Defaults via `{{ secrets_* | default('') }}`.

---

## Modus 1: Kein Vault (Standard)

### Wann nutzen?

- Neuer Host im Testbetrieb
- Features die Secrets brauchen werden nicht benötigt
- Schneller Start ohne Vault-Infrastruktur

### Was passiert?

Nichts Besonderes. Das Repo läuft out-of-the-box:

- `secrets_backend` steht auf `"ansible-vault"` (Default)
- Keine `secrets.yml` vorhanden → alle `secrets_*`-Variablen bleiben leer
- Consumer-Defaults resolvieren zu leeren Strings
- Roles prüfen `| length > 0` und **überspringen** Secret-abhängige Tasks

**Konkret werden übersprungen:**

| Feature                    | Guard-Bedingung                                |
|----------------------------|------------------------------------------------|
| msmtp Mail-Relay           | `common_msmtp_password \| length > 0`          |
| SSH Deploy Key             | `common_ssh_extra_keys \| length > 0`          |
| Status Monitor Credentials | `auto_update_statusmon_password \| length > 0` |

Alle anderen Features (Timezone, NTP, MOTD, Firewall, Docker, etc.) laufen normal.

### Einrichtung

Keine — das ist der Standardzustand. Einfach deployen:

```bash
make deploy                                              # Alle Hosts
make deploy LIMIT=0047-20.cloud.bauer-group.com          # Ein Host
```

### Bootstrap ohne Vault

```bash
curl -fsSL https://raw.githubusercontent.com/.../install.sh | \
  IAC_HOSTNAME=0047-20.cloud.bauer-group.com bash
```

---

## Modus 2: Ansible Vault

### Wann Ansible Vault nutzen?

- Secrets werden benötigt (SMTP, SSH-Keys, Status Monitor)
- Einzelner Verantwortlicher oder kleines Team
- Keine dynamische Rotation erforderlich
- Einfacher Start, minimaler Overhead

### Wie Ansible Vault funktioniert

- `secrets.yml` (AES-256 verschlüsselt) liegt out-of-band auf jedem Host
- `ansible-pull` entschlüsselt die Datei mit `/etc/ansible/vault-password`
- Ansible lädt `secrets_*`-Variablen automatisch aus `group_vars/all/secrets.yml`
- Consumer-Rollen (common, auto_update) pullen die Werte via Defaults

### Ansible Vault einrichten

#### Schritt 1: Vault-Datei erstellen

```bash
make vault-create               # Production
make vault-create ENV=staging   # Staging
```

Inhalt:

```yaml
---
# IAC-Ansible Vault Secrets
# Bearbeiten mit: make vault-edit

secrets_msmtp_password: "dein-smtp-passwort"
secrets_ssh_deploy_key: "ssh-ed25519 AAAA..."
secrets_statusmon_url: "https://status.example.com"
secrets_statusmon_username: "admin"
secrets_statusmon_password: "geheim"
```

#### Schritt 2: ansible-pull für Vault konfigurieren

In `group_vars/all/main.yml` die Vault-Passwort-Datei aktivieren:

```yaml
ansible_pull_vault_password_file: "/etc/ansible/vault-password"
```

Damit wird `--vault-password-file` an `ansible-pull` übergeben.

#### Schritt 3: Vault-Passwort auf Hosts verteilen

**Via install.sh (Bootstrap):**

```bash
curl -fsSL https://raw.githubusercontent.com/.../install.sh | \
  VAULT_PASSWORD="dein-vault-passwort" \
  IAC_HOSTNAME=0047-20.cloud.bauer-group.com bash
```

**Manuell:**

```bash
mkdir -p /etc/ansible
printf '%s' "dein-vault-passwort" > /etc/ansible/vault-password
chmod 0400 /etc/ansible/vault-password
```

#### Schritt 4: secrets.yml auf Hosts verteilen

Da `secrets.yml` nicht im Git-Repo liegt (out-of-band), muss die verschlüsselte
Datei separat auf jeden Host kopiert werden:

```bash
scp inventory/production/group_vars/all/secrets.yml \
  root@<host>:/opt/iac-ansible/inventory/production/group_vars/all/secrets.yml
```

### Tägliche Nutzung

```bash
make vault-edit              # Production Secrets bearbeiten
make vault-edit ENV=staging  # Staging Secrets bearbeiten
make vault-view              # Secrets temporär anzeigen (entschlüsselt)
make vault-rekey             # Vault-Passwort ändern (Rotation)
```

### Lokale Nutzung (Entwickler-Maschine)

Auf der lokalen Maschine ist kein `/etc/ansible/vault-password` nötig:

```bash
# Option A: Umgebungsvariable
export ANSIBLE_VAULT_PASSWORD_FILE=/pfad/zum/lokalen/passwort
make deploy

# Option B: Interaktiv
ansible-playbook -i inventory/production/hosts.yml playbooks/site.yml --ask-vault-pass
```

### Einzelnen Wert verschlüsseln

Für Inline-Verschlüsselung in Klartext-Dateien:

```bash
ansible-vault encrypt_string 'mein-geheimes-passwort' --name 'secrets_msmtp_password'
```

---

## Modus 3: HashiCorp Vault

### Wann HashiCorp Vault nutzen?

- Mehrere Teams mit eigenen Secrets (Team-Isolation)
- Super-Admin der alles sehen muss
- Automatische Secret-Rotation erforderlich
- Audit-Logging für Compliance
- Skalierung auf 10+ Hosts mit verschiedenen Zugriffsrechten

### Wie HashiCorp Vault funktioniert

- Phase 0 authentifiziert sich via AppRole am HashiCorp Vault Server
- Secrets werden per API aus dem KV v2 Store geholt
- `secrets_*`-Variablen werden per `set_fact` gesetzt
- Temporäre Credentials werden nach dem Fetch gelöscht
- Alle Tasks nutzen `no_log: true`

### Voraussetzungen

- HashiCorp Vault Server (v1.15+) mit KV v2 Secrets Engine
- `community.hashi_vault` Ansible Collection (bereits in `requirements.yml`)
- `hvac` Python Library (bereits in `requirements.txt`)
- Collection installieren: `make setup`

### Einrichtung

#### Schritt 1: Backend umschalten

In `inventory/production/group_vars/all/secrets_config.yml`:

```yaml
secrets_backend: "hashicorp-vault"

secrets_vault_addr: "https://vault.bauer-group.com:8200"
secrets_vault_auth_method: "approle"
secrets_vault_role_id_file: "/etc/iac-ansible/vault-role-id"
secrets_vault_secret_id_file: "/etc/iac-ansible/vault-secret-id"
secrets_vault_secret_path: "iac-ansible/shared"
secrets_vault_mount_point: "secret"
```

#### Schritt 2: KV v2 Secrets befüllen

```bash
vault kv put secret/iac-ansible/shared \
  msmtp_password="smtp-passwort" \
  ssh_deploy_key="ssh-ed25519 AAAA..." \
  statusmon_url="https://status.example.com" \
  statusmon_username="admin" \
  statusmon_password="monitor-passwort"
```

Erwartete Pfad-Struktur:

```
secret/data/iac-ansible/
├── shared/              ← Alle Hosts (msmtp, ssh, statusmon)
│   ├── msmtp_password
│   ├── ssh_deploy_key
│   ├── statusmon_url
│   ├── statusmon_username
│   └── statusmon_password
├── team-alpha/          ← Nur Team-Alpha-Hosts
│   └── ...
└── team-beta/           ← Nur Team-Beta-Hosts
    └── ...
```

#### Schritt 3: Policies erstellen

```hcl
# policy: iac-ansible-shared (für alle Hosts)
path "secret/data/iac-ansible/shared" {
  capabilities = ["read"]
}

# policy: iac-ansible-team-alpha (für Team-Alpha-Hosts)
path "secret/data/iac-ansible/team-alpha" {
  capabilities = ["read"]
}

# policy: iac-ansible-super-admin (sieht alles)
path "secret/data/iac-ansible/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
```

#### Schritt 4: AppRole einrichten

```bash
# AppRole aktivieren
vault auth enable approle

# Shared-Role für alle Hosts
vault write auth/approle/role/iac-ansible-shared \
  token_policies="iac-ansible-shared" \
  token_ttl=1h \
  token_max_ttl=4h \
  secret_id_ttl=720h \
  secret_id_num_uses=0

# Role-ID auslesen (einmalig, stabil)
vault read auth/approle/role/iac-ansible-shared/role-id

# Secret-ID generieren (pro Host, rotierbar)
vault write -f auth/approle/role/iac-ansible-shared/secret-id
```

#### Schritt 5: Credentials auf Hosts verteilen

**Via install.sh (Bootstrap):**

```bash
curl -fsSL https://raw.githubusercontent.com/.../install.sh | \
  VAULT_ROLE_ID="<role-id>" \
  VAULT_SECRET_ID="<secret-id>" \
  IAC_HOSTNAME=0047-20.cloud.bauer-group.com bash
```

**Manuell:**

```bash
mkdir -p /etc/iac-ansible
printf '%s' "<role-id>" > /etc/iac-ansible/vault-role-id
printf '%s' "<secret-id>" > /etc/iac-ansible/vault-secret-id
chmod 0400 /etc/iac-ansible/vault-role-id /etc/iac-ansible/vault-secret-id
```

### Team-Isolation

Teams erhalten eigene KV-Pfade und AppRoles.
Override per Inventory-Gruppe:

```yaml
# inventory/production/group_vars/team_alpha/secrets_config.yml
secrets_vault_secret_path: "iac-ansible/team-alpha"
```

Jedes Team bekommt eine eigene AppRole mit:

- `iac-ansible-shared` Policy (gemeinsame Secrets)
- `iac-ansible-team-<name>` Policy (eigene Secrets)

Der Super-Admin hat `iac-ansible-super-admin` und sieht alle Pfade.

### Secret-Rotation

| Was               | Wie                                                               | Frequenz                |
|-------------------|-------------------------------------------------------------------|-------------------------|
| Secret-Werte      | `vault kv put` mit neuen Werten — nächster ansible-pull übernimmt | Nach Bedarf             |
| AppRole secret_id | Neue secret_id generieren + auf Host deployen                     | Alle 30 Tage            |
| AppRole role_id   | Bleibt stabil pro Host-Klasse                                     | Nur bei Policy-Änderung |

---

## Backend wechseln

### Von Kein Vault zu Ansible Vault

1. `make vault-create` → Secrets eingeben
2. `ansible_pull_vault_password_file` in group_vars setzen
3. Vault-Passwort + `secrets.yml` auf Hosts verteilen
4. `make deploy`

### Von Ansible Vault zu HashiCorp Vault

1. HashiCorp Vault Server aufsetzen und Secrets befüllen
2. AppRole + Policies konfigurieren
3. AppRole-Credentials auf Hosts verteilen
4. In `secrets_config.yml` umschalten:

   ```yaml
   secrets_backend: "hashicorp-vault"
   secrets_vault_addr: "https://vault.bauer-group.com:8200"
   ```

5. `ansible_pull_vault_password_file` kann entfernt werden (nicht mehr nötig)
6. `make deploy` — die Secrets Role holt jetzt aus HashiCorp Vault

### Schrittweise Migration

Der Toggle kann **pro Host** gesetzt werden:

```yaml
# host_vars/test-host.yml — HashiCorp Vault für einen Host testen
secrets_backend: "hashicorp-vault"
secrets_vault_addr: "https://vault.bauer-group.com:8200"
```

Alle anderen Hosts bleiben auf `ansible-vault` bis die Migration validiert ist.

---

## Fehlverhalten und Troubleshooting

| Situation                                      | Verhalten                                          |
|------------------------------------------------|----------------------------------------------------|
| Kein Backend, kein secrets.yml                 | OK — leere Defaults, Secret-Features übersprungen  |
| Ansible Vault: secrets.yml fehlt               | OK — leere Defaults, Secret-Features übersprungen  |
| Ansible Vault: Passwort-Datei fehlt            | Fehler wenn secrets.yml vorhanden (kann nicht entschlüsseln) |
| Ansible Vault: secrets.yml + Passwort vorhanden | OK — Secrets geladen und gemappt                  |
| HashiCorp Vault: Server nicht erreichbar       | Fehler mit klarer Meldung (Vault-Adresse prüfen)  |
| HashiCorp Vault: AppRole-Dateien fehlen        | Fehler mit Hinweis auf fehlende Dateien            |
| HashiCorp Vault: Secret-Pfad nicht vorhanden   | Fehler (Pfad und Permissions prüfen)               |
| Falscher `secrets_backend`-Wert                | Sofortiger Assert-Fehler mit erlaubten Werten      |

### Debugging

```bash
# Dry-Run: prüfen ob Phase 0 durchläuft
make check LIMIT=0047-20.cloud.bauer-group.com

# Verbose: Secret-Status sehen (Ansible Vault Backend zeigt SET/EMPTY)
ansible-playbook -i inventory/production/hosts.yml playbooks/site.yml \
  --tags secrets --limit <host> -v
```

---

## Sicherheitshinweise

- Vault-Passwort **niemals** ins Git-Repo committen
- `.gitignore` enthält Muster für Passwort-Dateien und `secrets.yml`
- Credentials über sicheren Kanal verteilen (SSH, Cloud-Init Secrets)
- Alle HashiCorp Vault Tasks nutzen `no_log: true`
- Temporäre Credentials werden nach dem Fetch aus dem Speicher gelöscht
- Regelmäßig rotieren:
  - Ansible Vault: `make vault-rekey`
  - HashiCorp Vault: secret_id erneuern
- In CI/CD als Secret-Variable hinterlegen (`ANSIBLE_VAULT_PASSWORD`)
- Dateiberechtigungen: alle Credential-Dateien `0400` (root-only, read-only)

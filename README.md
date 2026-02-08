# IAS-Ansible

Infrastructure as Code mit Ansible - Git-basierte Konfigurationsverwaltung fur die Bauer Group.

## Quick Start

### Server bootstrappen (One-Liner)

```bash
curl -fsSL https://raw.githubusercontent.com/bauer-group/IAS-Ansible/main/scripts/install.sh | bash
```

### Cloud-Init

```yaml
#cloud-config
runcmd:
  - curl -fsSL https://raw.githubusercontent.com/bauer-group/IAS-Ansible/main/scripts/install.sh | bash
```

### Control Machine

```bash
git clone https://github.com/bauer-group/IAS-Ansible.git
cd IAS-Ansible
make setup
make deploy
```

## Architektur

```
GitHub Repo  ──pull──>  Server A (ansible-pull, systemd timer)
             ──pull──>  Server B (ansible-pull, systemd timer)
             ──pull──>  Server C ...
```

Jeder Server pruft taglich das Git-Repository auf Anderungen und wendet sie automatisch an. Alternativ kann ein sofortiger Push ausgelost werden.

## Verwendung

```bash
make help                                      # Alle Befehle anzeigen
make deploy                                    # Alle Server konfigurieren
make deploy LIMIT=0046-20.cloud.bauer-group.com  # Bestimmter Host
make deploy LIMIT="*.bauer-group.com"          # Wildcard
make update                                    # System-Updates ausfuhren
make check                                     # Dry-Run
make push LIMIT=<host>                         # Sofortiges Update auslosen
```

## Filterung

| Methode | Beispiel |
|---------|----------|
| Hostname | `LIMIT=server.example.com` |
| Wildcard | `LIMIT="*.bauer-group.com"` |
| IP-Bereich | `LIMIT="192.168.1.*"` |
| Gruppe | `LIMIT=auto_update` |
| Label | `LABEL=production` |
| Service | `SERVICE=nginx` |
| Tags | `TAGS=update` |

## Verzeichnisstruktur

```
inventory/         Hosts und Variablen (pro Environment)
playbooks/         Ansible Playbooks
roles/             Wiederverwendbare Rollen
  common/          Basis-Konfiguration (alle Hosts)
  auto_update/     Automatische System-Updates
  ansible_pull/    Git-basierter Pull-Mechanismus
scripts/           Bootstrap- und Hilfsscripte
filter_plugins/    Benutzerdefinierte Jinja2-Filter
docs/              Dokumentation
```

## Erster Workflow: Auto-Updates

Der Host `0046-20.cloud.bauer-group.com` (Ubuntu 24.04) ist konfiguriert mit:

- **Updates**: Taglich um 02:00 (alle Pakete oder nur Sicherheitsupdates, konfigurierbar)
- **Reboot**: Sonntags um 03:00 (nur wenn notig)
- **Steuerung**: Zentral in `inventory/production/group_vars/all/update_settings.yml`

Umschalten zwischen allen Updates und Sicherheitsupdates:

```yaml
# inventory/production/group_vars/all/update_settings.yml
auto_update_type: "all"       # Alle Updates
auto_update_type: "security"  # Nur Sicherheitsupdates
```

## Dokumentation

- [Architektur](docs/architecture.md)
- [Quickstart](docs/quickstart.md)
- [Filtering](docs/filtering.md)
- [Auto-Updates](docs/auto-updates.md)
- [Cloud-Init](docs/cloud-init.md)
- [Inventory-Verwaltung](docs/inventory-management.md)
- [Workflows](docs/workflows.md)

## Plattformen

| OS | Versionen | Status |
|----|-----------|--------|
| Ubuntu | 20.04, 22.04, 24.04 | Unterstutzt |
| Debian | 11, 12 | Unterstutzt |
| CentOS/RHEL | 8, 9 | Unterstutzt |
| Rocky/AlmaLinux | 8, 9 | Unterstutzt |

# SMART Disk Health Monitoring

## Überblick

Die SMART-Monitoring-Rolle überwacht die Gesundheit von SSDs und HDDs auf physischen Servern. Bei Problemen werden Alerts per Email gesendet.

**Zielgruppe:** Nur `physical_servers`-Gruppe (nicht auf VMs/Cloud-Instanzen).

## Features

- Automatische Erkennung aller SATA- und NVMe-Disks
- Korrekte `-d nvme` Erkennung für NVMe-Devices
- Email-Alerts bei Disk-Problemen
- `smartcheck`-Utility für schnelle manuelle Prüfung

## Voraussetzungen

Für Email-Alerts muss **msmtp** konfiguriert sein (Common-Rolle):

```yaml
# In group_vars/all/secrets.yml (encrypted via ansible-vault)
secrets_msmtp_password: "dein-smtp-passwort"
```

`common_msmtp_password` pullt den Wert automatisch aus `secrets_msmtp_password`.

Ohne msmtp funktioniert SMART-Monitoring trotzdem — Alerts werden dann nur ins Syslog geschrieben.

## Aktivierung

Server in die `physical_servers`-Gruppe aufnehmen:

```yaml
# inventory/production/hosts.yml
physical_servers:
  hosts:
    0001-00.cloud.bauer-group.com:
```

## Konfiguration

```yaml
# Defaults (überschreibbar in host_vars)
smartmon_alert_email: "support@support.bauer-group.com"

# Auto-Erkennung (empfohlen)
smartmon_auto_detect: true

# Oder manuelle Disk-Liste:
smartmon_auto_detect: false
smartmon_disks:
  - { device: "/dev/nvme0n1", type: "nvme" }
  - { device: "/dev/nvme1n1", type: "nvme" }
  - { device: "/dev/sda", type: "auto" }
  - { device: "/dev/sdb", type: "auto" }
```

## Was wird überwacht?

Für jede erkannte Disk:

| Flag | Beschreibung |
|------|-------------|
| `-a` | Alle SMART-Attribute prüfen |
| `-H` | Health-Status (PASSED/FAILED) |
| `-l error` | Error-Log überwachen |
| `-l selftest` | Self-Test Ergebnisse |
| `-f` | Bei Attribut-Änderung warnen |
| `-m` | Email an Alert-Adresse |

## Dateien auf dem Server

| Pfad | Beschreibung |
|------|-------------|
| `/etc/smartd.conf` | smartd Konfiguration (auto-generiert) |
| `/usr/local/sbin/smartcheck` | Quick-Check Utility Script |

## Nutzung

### Schneller Health-Check

```bash
smartcheck
```

Beispielausgabe:

```
/dev/nvme0n1: PASSED
/dev/nvme1n1: PASSED
/dev/sda: PASSED
/dev/sdb: PASSED
/dev/sdc: FAILED
```

### Detaillierter Status einer Disk

```bash
smartctl -a /dev/sda
```

### Manuellen Self-Test starten

```bash
# Kurzer Test (~2 Minuten)
smartctl -t short /dev/sda

# Langer Test (~Stunden, je nach Disk-Größe)
smartctl -t long /dev/sda

# Ergebnis prüfen
smartctl -l selftest /dev/sda
```

### Service-Status

```bash
systemctl status smartmontools
```

## Nur SMART-Monitoring deployen

```bash
# Via Makefile
make deploy LIMIT=0001-00.cloud.bauer-group.com TAGS=smartmon
```

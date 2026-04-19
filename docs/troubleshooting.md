# Troubleshooting

## ansible-pull schlägt fehl

### Symptom

`systemctl status ansible-pull` zeigt Fehler.

### Diagnose

```bash
# Logs prüfen
tail -50 /var/log/ansible/ansible-pull.log
journalctl -u ansible-pull --no-pager -n 50

# Manuell ausführen
systemctl start ansible-pull
```

### Häufige Ursachen

| Problem | Lösung |
|---------|--------|
| Git-Repository nicht erreichbar | Netzwerk/DNS prüfen, `git ls-remote` testen |
| Ansible-Version zu alt | `ansible_pull`-Rolle erneut ausführen (registriert PPA via signed-by keyring) |
| Vault-Passwort fehlt | `/etc/ansible/vault-password` erstellen (siehe [Vault-Doku](vault.md)) |
| Inventory nicht gefunden | `ansible_pull_inventory` in group_vars prüfen |

---

## SSH-Lockout nach Hardening

### Symptom

SSH-Zugang nach `common_ssh_hardening: true` verloren.

### Prävention

Die Role verweigert Hardening wenn keine SSH-Keys deployt sind. Trotzdem:

1. **Immer zuerst Keys prüfen:** `common_ssh_github_users` oder `common_ssh_extra_keys` setzen
2. **Console-Zugang sicherstellen** (Cloud-Provider Console, IPMI)
3. **Dry-Run zuerst:** `make check LIMIT=<host> TAGS=ssh`

### Recovery

```bash
# Via Cloud-Provider Console oder IPMI:
# 1. SSH-Config zurücksetzen
rm /etc/ssh/sshd_config.d/99-iac-hardening.conf
systemctl restart sshd

# 2. Password-Auth temporär aktivieren
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd
```

---

## Vault-Passwort fehlt

### Symptom

```
ERROR! Decryption failed on inventory/production/group_vars/all/secrets.yml
```

### Lösung

```bash
# Passwort auf Host deployen
printf '%s' "dein-passwort" > /etc/ansible/vault-password
chmod 0400 /etc/ansible/vault-password

# Oder: Vault-Datei entfernen (Features degradieren graceful)
rm /opt/iac-ansible/inventory/production/group_vars/all/secrets.yml
```

---

## Netplan-Rollback greift

### Symptom

Netzwerk-Änderung wird nach 2 Minuten automatisch zurückgesetzt.

### Erklärung

Die Netplan-Role nutzt einen Sicherheitsmechanismus: Ein systemd-Timer setzt die
Konfiguration automatisch zurück wenn der Connectivity-Test fehlschlägt.

### Diagnose

```bash
# Rollback-Timer prüfen
systemctl list-timers | grep netplan
# Netplan-Backup anschauen
ls -la /etc/netplan/*.bak
# Connectivity-Test manuell ausführen
ping -c 3 1.1.1.1
ping -c 3 -6 2001:4860:4860::8888
```

### Lösung

1. Netplan-Konfiguration in host_vars korrigieren
2. `make deploy LIMIT=<host> TAGS=netplan`
3. Warten bis Connectivity-Test erfolgreich ist (Timer wird abgebrochen)

---

## Docker startet nicht nach daemon.json-Änderung

### Symptom

```
Job for docker.service failed because the control process exited with error code.
```

### Diagnose

```bash
# daemon.json Syntax prüfen
python3 -c "import json; json.load(open('/etc/docker/daemon.json'))"

# Docker-Logs
journalctl -u docker --no-pager -n 30

# Häufig: IP-Konflikt mit vorhandenen Netzwerken
ip addr show docker0
```

### Lösung

```bash
# daemon.json reparieren oder zurücksetzen
cp /etc/docker/daemon.json.bak /etc/docker/daemon.json  # Falls Backup existiert
systemctl restart docker

# Oder: Docker-Netzwerke bereinigen und neu starten
systemctl stop docker
ip link delete docker0
systemctl start docker
```

---

## Allgemeine Diagnose

```bash
# Ansible-Version prüfen
ansible --version

# Inventory validieren
ansible-inventory -i inventory/production/hosts.yml --list

# Einzelnen Host testen
ansible -i inventory/production/hosts.yml <host> -m ping

# Dry-Run mit Diff
make check LIMIT=<host>

# Verbose-Output
ansible-playbook -i inventory/production/hosts.yml playbooks/site.yml --limit <host> -vvv
```

# Portainer

## Überblick

Die Portainer-Rolle installiert die Container-Management-Oberfläche **Portainer**
deklarativ über das `docker compose`-Plugin (`community.docker.docker_compose_v2`).

Anders als die übrigen Workloads der Flotte (die von Coolify deployed werden) ist
Portainer eine Infrastruktur-Komponente und wird daher direkt von Ansible verwaltet.

> **Wichtig:** Portainer und Coolify schließen sich auf einem Host gegenseitig aus.
> Die Rolle bricht mit einer klaren Fehlermeldung ab, wenn ein Host gleichzeitig
> für Coolify markiert ist (`coolify_hosts`-Gruppe oder Label `coolify`).

## Features

- Community Edition (CE, Standard) oder Business Edition (EE) — pro Host umschaltbar
- Erreichbarkeit nur über `127.0.0.1` (Standard) oder wahlweise öffentlich
- Admin-Benutzer wird beim ersten Start automatisch angelegt
  (`--admin-password-file`, kein 5-Minuten-Init-Timeout-Rennen)
- EE-Lizenz wird beim Start über die Umgebungsvariable `PORTAINER_LICENSE_KEY`
  eingespielt — kein API-Bootstrap nötig
- Updates durch erneutes Ausführen der Rolle (`pull: always`) — ersetzt das frühere
  manuelle `update_portainer.sh`
- Idempotent und nicht-destruktiv: der Container wird nur bei geändertem Image
  oder geänderter Compose-Konfiguration neu erstellt

## Aktivierung

Server in die `portainer_hosts`-Gruppe aufnehmen (zusätzlich `docker_hosts`, damit
die Docker-Rolle zuerst läuft):

```yaml
# inventory/production/hosts.yml
docker_hosts:
  hosts:
    0021-68.cloud.bauer-group.com:
portainer_hosts:
  hosts:
    0021-68.cloud.bauer-group.com:
```

Das Label `portainer` in der jeweiligen `host_vars/<host>.yml` ergänzen (für
`LABEL=portainer`-Filterung).

## Secrets

Beide Werte gehören in den verschlüsselten Vault (siehe [Secrets Management](vault.md)),
**niemals** in Klartext-Inventardateien:

| Secret | Pflicht | Beschreibung |
|--------|---------|--------------|
| `secrets_portainer_admin_password` | immer | Admin-Passwort, **mindestens 12 Zeichen**. Seedet den ersten Admin. |
| `secrets_portainer_license` | nur EE | Portainer-Business-Lizenzschlüssel. |

Ansible-Vault-Backend — in `group_vars/all/secrets.yml` (verschlüsselt):

```yaml
secrets_portainer_admin_password: "<min. 12 Zeichen>"
secrets_portainer_license: "<Lizenzschlüssel>"   # nur bei edition == ee
```

HashiCorp-Vault-Backend — als Keys `portainer_admin_password` /
`portainer_license` unter dem konfigurierten KV-Pfad.

## Konfiguration

Die wichtigsten Variablen (vollständig in `roles/portainer/defaults/main.yml`):

| Variable | Standard | Beschreibung |
|----------|----------|--------------|
| `portainer_edition` | `ce` | `ce` (Community) oder `ee` (Business) |
| `portainer_expose_public` | `false` | `true` veröffentlicht auf allen Interfaces (`0.0.0.0` / `[::]`) |
| `portainer_image` | `portainer/portainer-{{ edition }}:latest` | Container-Image |
| `portainer_project_dir` | `/opt/portainer` | Compose-Projektverzeichnis |
| `portainer_port_https` | `9443` | HTTPS-UI-Port |

Beispiel — EE, öffentlich erreichbar (z. B. `group_vars/portainer_hosts/main.yml`
oder pro Host):

```yaml
portainer_edition: "ee"
portainer_expose_public: true
```

## Netzwerk / Exposure

Standardmäßig bindet Portainer nur auf `127.0.0.1` und `[::1]` (Ports 8000, 9000,
9443). Für öffentlichen Zugriff `portainer_expose_public: true` setzen.

> **Achtung (UFW + Docker):** Veröffentlichte Container-Ports umgehen UFW, da Docker
> eigene iptables-Regeln davor einfügt. Öffentliche Exposure am Provider-/Edge-Firewall
> absichern oder Portainer hinter Traefik betreiben.

## Updates

Erneut deployen aktualisiert das Image (`pull: always` → Neuerstellung nur bei
neuerem Image):

```bash
make deploy LIMIT=0021-68.cloud.bauer-group.com TAGS=portainer
```

## Admin-Passwort zurücksetzen

`--admin-password-file` legt den Admin nur beim **ersten** Start an und ändert ein
bestehendes Passwort **nicht**. Zum Zurücksetzen den offiziellen Helfer nutzen:

```bash
docker stop portainer
docker run --rm -v portainer:/data portainer/helper-reset-password
docker start portainer
```

## Verifikation

```bash
docker ps                                              # Container "portainer" läuft
curl -k https://127.0.0.1:9443/api/system/status       # 200 OK
curl -k https://127.0.0.1:9443/api/users/admin/check   # 204 = Admin existiert
```

Anschließend mit den Vault-Admin-Zugangsdaten anmelden; bei EE in den Einstellungen
prüfen, dass die Lizenz aktiv ist.

# Docker Runtime

## Überblick

Die Docker-Rolle installiert Docker CE mit Compose-Plugin, konfiguriert IPv6 Dual-Stack Networking und richtet automatische Bereinigung ein.

## Features

- Docker CE aus dem offiziellen Docker-Repository (nicht `docker.io`)
- Docker Compose v2 als Plugin (`docker compose`)
- IPv6 Dual-Stack mit NAT-Masquerading
- Custom Bridge-IP (kein Konflikt mit Corporate VPNs)
- Log-Rotation für Container-Logs
- Wöchentliche Bereinigung ungenutzter Ressourcen
- `vm.max_map_count` für Elasticsearch/OpenSearch

## Aktivierung

Server in die `docker_hosts`-Gruppe aufnehmen:

```yaml
# inventory/production/hosts.yml oder inventory/staging/hosts.yml
docker_hosts:
  hosts:
    0021-68.cloud.bauer-group.com:
```

## Was wird installiert?

| Paket | Beschreibung |
|-------|-------------|
| `docker-ce` | Docker Engine |
| `docker-ce-cli` | Docker CLI |
| `containerd.io` | Container Runtime |
| `docker-buildx-plugin` | Multi-Platform Builds |
| `docker-compose-plugin` | Compose v2 (`docker compose`) |
| `ip6tables` | IPv6 Firewall (für NAT) |

Konfligierende Pakete (`docker.io`, `podman-docker`, etc.) werden automatisch entfernt.

## Netzwerk-Konfiguration

### Docker Bridge

```json
{
  "bip": "10.0.0.1/9",
  "default-address-pools": [
    { "base": "10.128.0.0/9", "size": 24 },
    { "base": "fdff:8000::/17", "size": 64 }
  ]
}
```

- **Bridge-IP `10.0.0.1/9`**: Vermeidet Konflikte mit typischen Corporate-Netzen (`172.16.0.0/12`)
- **Address Pools**: Jedes Docker-Network bekommt ein `/24` (IPv4) bzw. `/64` (IPv6) Subnet

### IPv6

```json
{
  "ipv6": true,
  "fixed-cidr-v6": "fdff::/17"
}
```

Der `docker-support.service` richtet IPv6-NAT ein:

```
ip6tables -t nat -A POSTROUTING -s fdff::/16 ! -o docker0 -j MASQUERADE
```

Damit können Container über IPv6 nach außen kommunizieren.

## Konfigurierbare Variablen

In `host_vars` oder `group_vars` überschreibbar:

```yaml
# Docker daemon (komplettes JSON)
docker_daemon_options:
  bip: "10.0.0.1/9"
  ipv6: true
  fixed-cidr-v6: "fdff::/17"
  log-driver: "json-file"
  log-opts:
    max-size: "10m"
    max-file: "3"
  storage-driver: "overlay2"

# IPv6 NAT
docker_ipv6_nat_enabled: true
docker_ipv6_nat_subnet: "fdff::/16"

# Kernel-Parameter
docker_sysctl:
  vm.max_map_count: 4194304

# Auto-Prune (Sonntag 04:30)
docker_prune_enabled: true
docker_prune_cron_hour: "4"
docker_prune_cron_minute: "30"
docker_prune_cron_weekday: "0"
```

## Dateien auf dem Server

| Pfad | Beschreibung |
|------|-------------|
| `/etc/docker/daemon.json` | Docker Daemon Konfiguration |
| `/etc/sysctl.d/98-docker.conf` | Kernel-Parameter |
| `/etc/systemd/system/docker-support.service` | IPv6 NAT Service |

## Nutzung nach Installation

```bash
# Docker testen
docker run hello-world

# Compose testen
docker compose version

# Container starten
docker compose -f /pfad/zu/compose.yml up -d
```

## Nur Docker deployen

```bash
# Via ansible-pull (auf dem Server)
ansible-pull --url https://github.com/bauer-group/IAC-Ansible.git \
  --checkout main --directory /opt/iac-ansible --full \
  --tags docker playbooks/site.yml

# Via Makefile (remote)
make deploy LIMIT=0021-68.cloud.bauer-group.com TAGS=docker
```

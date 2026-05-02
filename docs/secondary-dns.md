# Secondary DNS (PowerDNS)

Pure-authoritative PowerDNS slave/secondary, deployed via the `secondary_dns`
role. Mirrors the reference setup at
[bauer-group/IP-Helper.SecondaryDNS](https://github.com/bauer-group/IP-Helper.SecondaryDNS),
adapted to the IAC-Ansible conventions: chrony, fail2ban-sshd, msmtp, SSH
hardening, MOTD, hostname management, NTP and unattended-upgrades come from
the `common` and `auto_update` baselines — the `secondary_dns` role only
adds PowerDNS-specific bits on top.

## What the role does

| Concern | Owner |
| --- | --- |
| PowerDNS authoritative + sqlite3 backend | `secondary_dns` |
| `dns-admin` runtime tool | `secondary_dns` |
| Disable `systemd-resolved` (port 53 conflict) + static `/etc/resolv.conf` | `secondary_dns` |
| Sysctl tuning for high-rate UDP/TCP DNS | `secondary_dns` |
| UFW rules for `53/tcp` + `53/udp` | `secondary_dns` |
| SQLite schema, supermasters from inventory, optional TSIG key | `secondary_dns` |
| chrony, NTP, msmtp, hostname, MOTD, locale, sysctl `nofile`, fail2ban [sshd] + [recidive] | `common` |
| Daily security updates + weekly reboot | `auto_update` |

The role is fully **idempotent**: re-runs are no-ops on a converged host. The
SQLite schema uses `CREATE IF NOT EXISTS`, supermaster rows are inserted
with `INSERT OR IGNORE`, and the `pdns.conf` template includes the
`# BEGIN PRIMARY-IPS / # END PRIMARY-IPS` markers so `dns-admin` can rewrite
the allow-list at runtime without conflicting with the next deploy.

## Architecture

```text
                       INTERNET
                          |
                          v
     +-------------------------------------+
     |     SECONDARY DNS (PowerDNS)        |
     |  asset:  0001-35.cloud.bauer-group  |
     |  service ns1.professional-hosting   |
     |                                     |
     |  - Known zone   -> authoritative    |
     |  - Unknown zone -> REFUSED          |
     +-------------------------------------+
            ^               ^               ^
            | NOTIFY/AXFR   |               |
            |               |               |
   +--------+-------+ +-----+--------+ +----+--------+
   | Primary 1      | | Primary 2    | | Primary N   |
   | IPv4 + IPv6    | | IPv4 + IPv6  | | IPv4 + IPv6 |
   +----------------+ +--------------+ +-------------+
```

## Adding a new secondary

### 1. Pick the asset number

Use the [server-naming scheme](server-naming.md): a DNS service running on
a virtual machine is **group 35** (cloud service on VM). The asset ID is
the next free four-digit number.

Example: `0001-35.cloud.bauer-group.com`.

The customer-facing service name (e.g. `ns1.professional-hosting.com`) is a
**plain A/AAAA record** that resolves to the host's IP — it is **not** the
system hostname. See the [Service FQDNs vs. asset FQDN](server-naming.md#service-fqdns-vs-asset-fqdn)
section.

### 2. Inventory wiring

Add the host to the relevant groups in
`inventory/production/hosts.yml`:

```yaml
cloud_services:
  hosts:
    0001-35.cloud.bauer-group.com:

debian:
  children:
    debian_13:
      hosts:
        0001-35.cloud.bauer-group.com:

auto_update:
  hosts:
    0001-35.cloud.bauer-group.com:

secondary_dns:
  hosts:
    0001-35.cloud.bauer-group.com:
```

### 3. host_vars

Create `inventory/production/host_vars/<asset>.yml`. The minimum required
key is `secondary_dns_primaries` — without it the role refuses to deploy
(an unconfigured secondary is useless).

```yaml
platform: debian_13
asset_id: "0001"
group_code: "35"
asset_type: dns_secondary

service_fqdns:
  - ns1.professional-hosting.com

# UFW enabled; the role opens 53/tcp + 53/udp
common_firewall_ufw_state: "enabled"

# Disable common's resolved hardening — this host RUNS the resolver
common_resolved_configure: false

secondary_dns_primaries:
  - hostname: "ns1.example.com"   # MUST match the SOA MNAME (NOT reverse-DNS)
    ipv4: "203.0.113.10"
    ipv6: "2001:db8::10"
  - hostname: "ns2.example.com"
    ipv4: "203.0.113.11"
    ipv6: "2001:db8::11"
```

### 4. Bootstrap + deploy

Provision the box with cloud-init (or `scripts/install.sh`), then:

```bash
make deploy LIMIT=0001-35.cloud.bauer-group.com
```

The role will:

1. Stop + mask `systemd-resolved` and replace `/etc/resolv.conf`.
2. Install `pdns-server`, `pdns-backend-sqlite3`, `sqlite3`, `dnsutils`.
3. Create the SQLite schema and seed `supermasters` from `secondary_dns_primaries`.
4. Render `pdns.conf` with the inventory IPs in the `BEGIN/END PRIMARY-IPS`
   block, validate it with `pdns_server --config`, then start the service.
5. Open `53/tcp` + `53/udp` in UFW (only when UFW is active).
6. Wait for port 53 to bind, then run `dns-admin health` as a smoke test.

## MNAME pitfall (the #1 source of "secondary doesn't see my zone")

PowerDNS in **autosecondary** mode accepts a NOTIFY only when the source IP
**and** the SOA's MNAME match an entry in the `supermasters` table. The MNAME
is **not** the reverse-DNS of the primary's IP — it is whatever the primary
puts in the SOA record.

Plesk and BIND often differ from what operators expect. If a NOTIFY is being
refused, run on the secondary:

```bash
sudo dns-admin primary discover <primary-ip> <known-zone>
```

It will query the SOA, extract the MNAME, and tell you whether it is in
`supermasters` — and if not, suggest the exact `primary add` command. The
recommended fix is to add the MNAME to `secondary_dns_primaries` in the
inventory so disaster recovery from a fresh image restores it automatically.

## Inventory vs. runtime: who owns the primary list?

There are two ways to add a primary:

| Method | Persists across `ansible-pull`? | Use when |
| --- | --- | --- |
| Inventory (`secondary_dns_primaries`) | yes — declarative | Permanent primaries; the source of truth for disaster recovery |
| `dns-admin primary add` (runtime) | yes (default), or **no** if `secondary_dns_primaries_strict: true` | Temporary additions, MNAME-discovery experiments, on-call hotfixes |

Default behaviour is **additive**: Ansible inserts inventory primaries with
`INSERT OR IGNORE`, so runtime additions are not deleted on the next deploy.
This is intentional — operators must be able to add a primary in an
incident without first opening a PR.

To enforce inventory-only mode (drop everything not in the inventory), set
`secondary_dns_primaries_strict: true` in `host_vars/` or in
`group_vars/secondary_dns/main.yml`.

## Operations

```bash
# On the host
dns-admin status                       # Full server status
dns-admin health                       # Health check (exit 0/1/2 — for monitoring)
dns-admin stats                        # PowerDNS counter dump
dns-admin primary list                 # Configured primaries
dns-admin primary verify example.com   # ACTIVE diagnostic per primary
dns-admin zone list                    # Synced zones
dns-admin zone retrieve example.com    # Force AXFR
dns-admin tsig list                    # Configured TSIG keys
```

### `dns-admin primary verify` — what it does

This command is a meaningful improvement over the upstream tool. For each
configured primary it:

1. Queries the SOA of the given zone with a 5-second timeout (measures latency).
2. Extracts the MNAME from the SOA reply.
3. Compares it against the `nameserver` column in `supermasters`.
4. Prints `[OK]` / `[WARN] mismatch` / `[FAIL] unreachable` per primary.
5. Exits with `0` (all OK), `1` (at least one MNAME mismatch — NOTIFY would be
   refused), or `2` (at least one primary unreachable).

Use it after changes on the primary side, after firewall changes, or in
on-call playbooks to confirm the secondary will actually accept what the
primary sends.

### `dns-admin tsig` — runtime TSIG management

The upstream tool only supports TSIG through the install-time `.env`. This
role's `dns-admin` adds the full lifecycle:

```bash
sudo dns-admin tsig add transfer-key hmac-sha256 BASE64SECRET==
sudo pdnsutil set-meta example.com AXFR-MASTER-TSIG transfer-key
dns-admin tsig list                  # secret is masked, only first 8 chars shown
sudo dns-admin tsig remove transfer-key
```

For persistence across re-images, also set `secondary_dns_tsig_key` in
`group_vars/secondary_dns/main.yml` (or in `host_vars`, ideally vaulted).

```bash
# From the control machine
make push LIMIT=0001-35.cloud.bauer-group.com   # Trigger immediate ansible-pull
make deploy LIMIT=secondary_dns                 # Re-deploy all secondaries
```

## Variables (selected)

See [`roles/secondary_dns/defaults/main.yml`](../roles/secondary_dns/defaults/main.yml)
for the full list.

| Variable | Default | Purpose |
| --- | --- | --- |
| `secondary_dns_enabled` | `true` | Master switch — `false` makes the role a no-op |
| `secondary_dns_primaries` | `[]` | List of `{hostname, ipv4, ipv6}` — required |
| `secondary_dns_primaries_strict` | `false` | Drop runtime entries not in inventory |
| `secondary_dns_tsig_key` | `""` | Optional `name:algo:secret` for signed AXFR |
| `secondary_dns_local_address` | `"0.0.0.0,::"` | Bind interfaces |
| `secondary_dns_host_resolvers` | Quad9 v4 + v6 | What `/etc/resolv.conf` points at |
| `secondary_dns_sysctl_tune` | `true` | Deploy `99-dns-performance.conf` |
| `secondary_dns_firewall_open` | `true` | Open 53/tcp + 53/udp in UFW (when active) |

The `[recidive]` fail2ban jail is now provided by the `common` role
(`common_fail2ban_recidive_enabled`, default `true`) and applies to every host.

## See also

- Reference repository:
  [bauer-group/IP-Helper.SecondaryDNS](https://github.com/bauer-group/IP-Helper.SecondaryDNS)
- [Server naming](server-naming.md) — and the **Service FQDNs vs. asset FQDN** rule
- [Auto-updates](auto-updates.md) — applies to DNS hosts as it does to any other
- [Host onboarding](host-onboarding.md)

# k0s — Bare-Metal Kubernetes

The `k0s` role provisions and operates k0s-based Kubernetes clusters on
bare-metal or VPS hosts, integrated with the existing `ansible-pull` model.

## Two network scenarios

The role supports two clearly separated cluster network modes. One role,
one variable (`k0s_network_mode`), two operational realities:

### Scenario A — `vlan` (datacenter)

Hosts share a managed switch (dot1q-capable). The role creates a VLAN
sub-interface (`eth0.<vlan_id>`, default ID 1000) via netplan and binds
all k0s/etcd/CNI traffic to the VLAN-internal address.

- No BGP, no Anycast, no ToR-side configuration
- API HA via k0s' built-in NLLB (per-kubelet Envoy)
- Optional CPLB (keepalived/VRRP) for a real VIP
- Reuses the rollback-timer pattern from `roles/common/tasks/netplan.yml`

### Scenario B — `overlay` (public-network "soft vSwitch")

Hosts have only public IPs (e.g. different VPS providers). The role
builds a WireGuard full-mesh between all cluster members; k0s/etcd/CNI
listen on the encrypted `wg0` overlay only.

- WireGuard keypair generated on first run (idempotent)
- Pubkey + endpoint published to HashiCorp Vault per host
- Peer list is read from Vault on every pull → mesh self-converges
- MTU 1380 (avoids stealthy fragmentation in TLS handshakes)
- `PersistentKeepalive=25` keeps NAT/conntrack mappings warm

## Multi-cluster topology

`k0s_cluster_id` is the per-host identifier. Each cluster has its own etcd,
its own Vault namespace (`k0s/<cluster_id>/...`) and its own overlay subnet.
Inventory layout:

```yaml
k0s_clusters:
  children:
    k0s_cluster_prod_dc_de1:
      hosts: { 0050-00..., 0051-00..., 0052-00... }
      vars:
        k0s_cluster_id: "prod-dc-de1"
        k0s_network_mode: "vlan"
    k0s_cluster_prod_public:
      hosts: { 0080-20..., 0081-20..., 0082-20... }
      vars:
        k0s_cluster_id: "prod-public"
        k0s_network_mode: "overlay"

k0s_cluster:
  children:
    k0s_clusters:
```

## Pure-pull bootstrap

There is no operator host and no `k0sctl`. The cluster bootstraps itself
via two host-level flags:

- Exactly one host per cluster carries `k0s_bootstrap_node: true`
- All other hosts carry the default (`false`)

Sequence (time-ordered, not Ansible-serial):

1. Bootstrap node detects an empty `/var/lib/k0s` and runs
   `k0s install controller --config /etc/k0s/k0s.yaml`
2. After kube-apiserver `/readyz` returns 200, fresh tokens are minted
   (`k0s token create --role=<role> --expiry=25h`) and pushed to Vault
3. Other nodes pull, find the token in Vault, run
   `k0s install <role> --token-file ...` and start
4. Joiners that pull before the bootstrap node finds tokens in Vault
   simply `meta: end_host` and retry on the next pull cycle

Token TTL (25h) slightly exceeds the daily pull interval, so a valid
token is always available without long-lived secrets.

## API high availability

| Mode | Where | Why |
|------|-------|-----|
| **NLLB** (default) | `vlan` and `overlay` | Per-kubelet Envoy, no external dependency, identical in both scenarios |
| **CPLB** (optional) | `vlan` only | k0s-managed keepalived+haproxy → real VIP, requires L2 connectivity |
| BGP/Anycast | not built-in | Out-of-scope; add a separate `k0s_bgp` role if needed |

## HashiCorp Vault is mandatory

The role asserts `secrets_backend == "hashicorp-vault"`. Ansible-Vault is
not supported because tokens are rotated on every pull and Vault is the
only backend that allows in-pull writes without a git push-back loop.

Vault paths used by the role:

```
secret/k0s/<cluster_id>/tokens                 # controller_token, worker_token
secret/k0s/<cluster_id>/wg/<inventory_hostname> # pubkey, endpoint, allowed_ips
```

## Variable cheat sheet

```yaml
# Identity
k0s_cluster_id: "prod-dc-de1"           # required
k0s_role: "controller+worker"           # controller | worker | controller+worker
k0s_bootstrap_node: false               # exactly one true per cluster

# Version
k0s_version: "v1.31.0+k0s.0"
k0s_upgrade_allowed: false              # explicit gate against accidental upgrades

# Network mode
k0s_network_mode: "vlan"                # vlan | overlay

# vlan
k0s_vlan_id: 1000
k0s_vlan_address: "10.10.0.5/24"        # required per host

# overlay
k0s_overlay_subnet: "10.99.0.0/24"
k0s_overlay_address: ""                 # default: derived from asset_id
k0s_overlay_public_endpoint: ""         # default: ansible_default_ipv4 + listen_port

# API HA
k0s_nllb_enabled: true
k0s_cplb_enabled: false                 # vlan-only

# Test mode
k0s_test_mode: false                    # set true in molecule / dry-run
```

## Operating

```bash
make k0s LIMIT='*-cluster.bauer-group.com'   # apply k0s phase only
make k0s-status LIMIT='*-cluster.bauer-group.com'
```

Underneath: tagged invocation `--tags k0s` against `playbooks/site.yml`.
The pull mechanism applies the same phase daily without manual action.

## Verification

```bash
cd roles/k0s
molecule test -s default     # vlan scenario, test-mode
molecule test -s overlay     # wireguard scenario, test-mode
```

Real cluster verification (after first apply on staging sandbox):

```bash
ssh 0001-68.cloud.bauer-group.com
k0s status
kubectl --kubeconfig /var/lib/k0s/pki/admin.conf get nodes -o wide
kubectl --kubeconfig /var/lib/k0s/pki/admin.conf get pods -A
```

## Out-of-scope

- MAAS or PXE-based provisioning (orthogonal — covered by provider tooling)
- BGP/Anycast (separate `k0s_bgp` role if a future use case requires it)
- MetalLB / Traefik / cert-manager (separate `k0s_metallb`, `k0s_traefik`,
  `k0s_cert_manager` roles, single-responsibility per BG standards)
- etcd backup automation (separate `k0s_backup` role; integrate with MinIO)

## References

- [k0s documentation](https://docs.k0sproject.io/)
- [Vault Strategy](vault.md)
- Memory: `project_k0s_secrets.md` (k0s requires HashiCorp Vault)

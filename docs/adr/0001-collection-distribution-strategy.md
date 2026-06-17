# ADR-0001: Ansible collection distribution strategy

- Status: Accepted
- Date: 2026-06-17
- Deciders: BAUER GROUP infrastructure

## Context

Ansible Galaxy collections enter this project through two distinct paths:

- **Control node + CI** install the pinned versions from `requirements.yml`
  (`make setup` runs `ansible-galaxy install -r requirements.yml`, and the
  molecule CI step does `ansible-galaxy collection install -r requirements.yml
  --force`; every molecule scenario also lists it as its galaxy dependency).
- **Managed hosts** do *not*. Neither `scripts/install.sh` nor the
  `ansible_pull` role install `requirements.yml`. Hosts run with the
  collections **bundled in the apt `ansible` package** they install (from the
  Launchpad PPA on 22.04/24.04, or universe on 26.04+).

Consequence: the collection versions exercised in CI (currently
`community.general` 13.x, `community.hashi_vault` 7.x) can differ from the
versions a host actually runs (whatever its apt `ansible` package bundles).

The question raised: should managed hosts also install `requirements.yml` via
`ansible-pull`, so CI tests exactly what hosts run?

The collection surface the roles actually depend on is small and long-stable:

| Collection | Modules / plugins used | Where |
| --- | --- | --- |
| `community.general` | `ufw`, `modprobe`, `locale_gen`, `timezone`, `dict` | common, secondary_dns, k0s, smartmon |
| `ansible.utils` | `ipaddr`, `ipmath` (filters) | k0s |
| `community.hashi_vault` | `vault_kv` (lookup) | secrets, k0s (HashiCorp Vault backend) |
| `ansible.posix` | none by FQCN (declared dependency only) | — |

All of these are mature, behaviourally-stable modules; none rely on features
introduced in a recent collection major. The divergence is therefore
theoretical for the current usage, not practical.

## Decision

Keep the current split. **Do not install `requirements.yml` on managed hosts
via `ansible-pull`.** Hosts stay self-contained on the apt `ansible` package's
bundled collections; `requirements.yml` pins only the control-node and
CI/molecule toolchain.

## Consequences

Positive:

- Managed hosts have **zero Galaxy network dependency at runtime** — a
  configuration run cannot be blocked by a galaxy.ansible.com outage or rate
  limit. Hosts stay self-contained (apt is the only external dependency, which
  is already required).
- No extra bootstrap moving parts (collection path, install ordering).
- Lean / YAGNI: no machinery added to solve a non-problem.

Accepted trade-off:

- CI and hosts may run different collection versions. This is acceptable
  **only while the roles use long-stable modules** (the table above). The
  standing discipline: a role must use only modules present in the oldest
  supported apt `ansible` package baseline.

## Alternatives considered

1. **Install `requirements.yml` on hosts via `ansible-pull`** — rejected.
   Adds a runtime Galaxy network dependency on every pull, plus bootstrap
   complexity, to fix a divergence that is benign for the current module set.
2. **Vendor collections into the repo** (committed `collections/` tree) —
   deferred. This is the preferred Plan B *if* a hard requirement arises,
   because it pins auditable versions with no runtime network dependency.

## Revisit when

- A role needs a collection feature newer than the oldest supported apt
  `ansible` package bundles → the host-side version must then be controlled.
- A supply-chain / reproducibility requirement (CRA, NIS2, SBOM) mandates
  pinned, auditable host-side collection versions → adopt **vendoring**
  (alternative 2), not runtime Galaxy.

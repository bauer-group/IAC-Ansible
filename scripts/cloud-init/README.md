# Cloud-Init Bootstrap Files

Per-host cloud-init user-data files. One file per inventory host, mirroring the
inventory layout — that way `inventory/<env>/host_vars/<fqdn>.yml` and
`scripts/cloud-init/<env>/<fqdn>.yml` always travel together.

```text
scripts/cloud-init/
├── production/        -> hosts in inventory/production/hosts.yml
└── staging/           -> hosts in inventory/staging/hosts.yml
```

## Branch policy

Both environments currently track the **`main`** branch. Separation between
production and staging happens via the `INVENTORY` variable passed to
`install.sh`, **not** via separate git branches. Each cloud-init file pins its
target inventory explicitly — there is no implicit default.

| Environment | Inventory | Branch |
| --- | --- | --- |
| Production | `inventory/production/hosts.yml` | `main` |
| Staging | `inventory/staging/hosts.yml` | `main` |

## Two ways to deploy any of these files

Each file's header comment names both:

1. **Cloud-init (unattended)** — paste the file content into the provider's
   user-data field, or use `--user-data-from-file`.
2. **Manual one-liner** — SSH into a freshly-installed Ubuntu/Debian box as
   root and run the documented `curl … | … bash` invocation.

Both paths converge on the same end state: hostname set, Ansible installed,
ansible-pull timer enabled, first pull executed against the correct inventory.
Idempotent — safe to re-run.

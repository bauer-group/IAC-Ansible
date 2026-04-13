# Contributing to IAC-Ansible

## Setup

```bash
git clone https://github.com/bauer-group/IAC-Ansible.git
cd IAC-Ansible
make setup
pre-commit install
```

## Development Workflow

```bash
# 1. Make changes to roles/playbooks
# 2. Lint
make lint

# 3. Test the affected role
cd roles/<role>
molecule test

# 4. Dry-run against a host
make check LIMIT=<hostname>

# 5. Commit (Semantic Commits, past tense)
git commit -m "feat(common): added new feature X"
```

## Commit Convention

Format: `type(scope): subject in past tense`

| Type | When |
|------|------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Restructuring without feature/fix |
| `docs` | Documentation only |
| `test` | Tests |
| `chore` | Maintenance |

Subject rules: past tense, max 50 characters, no period.

## Role Development

### Naming Convention

- Role defaults: `rolename_variable_name`
- Vault variables: `vault_variable_name`
- Task names: descriptive, action-oriented (e.g., "Deploy Docker daemon configuration")

### Required Structure

```
roles/<role>/
  defaults/main.yml          # All configurable variables with defaults
  tasks/main.yml             # Main task orchestration
  handlers/main.yml          # Service restart handlers (if applicable)
  templates/                 # Jinja2 templates
  meta/main.yml              # Role metadata + dependencies
  molecule/default/          # Molecule test scenario
    molecule.yml
    converge.yml
    verify.yml
```

### Checklist

- [ ] All variables have defaults in `defaults/main.yml`
- [ ] Variables use `rolename_` prefix
- [ ] Tasks are idempotent (run twice = no changes)
- [ ] Sensitive tasks use `no_log: true`
- [ ] File permissions are explicit (`mode: "0644"`)
- [ ] Molecule tests pass: `cd roles/<role> && molecule test`
- [ ] Linting passes: `make lint`

## Pre-Commit Hooks

Pre-commit runs automatically on `git commit`:

- **trailing-whitespace**: removes trailing spaces
- **end-of-file-fixer**: ensures newline at end of file
- **check-yaml**: validates YAML syntax
- **yamllint**: enforces YAML style (`.yamllint`)
- **ansible-lint**: validates Ansible best practices (`.ansible-lint`)

To run manually: `pre-commit run --all-files`

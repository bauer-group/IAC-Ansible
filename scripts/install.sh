#!/bin/bash
# =============================================================================
# IAC-Ansible: One-Line Installer / Cloud-Init Bootstrap
# =============================================================================
#
# Quick install:
#   curl -fsSL https://raw.githubusercontent.com/bauer-group/IAC-Ansible/main/scripts/install.sh | bash
#
# With options:
#   curl -fsSL https://raw.githubusercontent.com/bauer-group/IAC-Ansible/main/scripts/install.sh | \
#     BRANCH=main PLAYBOOK=playbooks/site.yml bash
#
# Set inventory hostname during bootstrap (matches host_vars/<name>.yml):
#   curl -fsSL https://raw.githubusercontent.com/bauer-group/IAC-Ansible/main/scripts/install.sh | \
#     IAC_HOSTNAME=0047-20.cloud.bauer-group.com bash
#
# Cloud-Init (in user-data):
#   runcmd:
#     - curl -fsSL https://raw.githubusercontent.com/bauer-group/IAC-Ansible/main/scripts/install.sh | bash
#
# =============================================================================

set -euo pipefail

# --- Configuration (override via environment variables) ---
REPO_URL="${REPO_URL:-https://github.com/bauer-group/IAC-Ansible.git}"
BRANCH="${BRANCH:-main}"
WORKDIR="${WORKDIR:-/opt/iac-ansible}"
PLAYBOOK="${PLAYBOOK:-playbooks/site.yml}"
INVENTORY="${INVENTORY:-inventory/production/hosts.yml}"
LOG_FILE="${LOG_FILE:-/var/log/ansible/ansible-pull.log}"
SCHEDULE="${SCHEDULE:-*-*-* 02:00:00}"
RANDOM_DELAY="${RANDOM_DELAY:-900}"
LOCK_FILE="/var/run/iac-ansible-install.lock"
MARKER_FILE="/etc/iac-ansible-bootstrapped"

# Optional: inventory hostname to set before ansible-pull self-identifies.
# When set, the script writes it to hostnamectl, /etc/hosts and cloud-init
# so ansible-pull finds the matching inventory entry (and its host_vars).
# Leave empty to keep the previous, system-managed hostname.
IAC_HOSTNAME="${IAC_HOSTNAME:-}"

# Optional: vault credentials (out-of-band secret provisioning)
# Ansible Vault: password for decrypting secrets.yml
VAULT_PASSWORD="${VAULT_PASSWORD:-}"
# HashiCorp Vault: AppRole credentials for API-based secret retrieval
VAULT_ROLE_ID="${VAULT_ROLE_ID:-}"
VAULT_SECRET_ID="${VAULT_SECRET_ID:-}"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[IAC-Ansible]${NC} $*"; }
warn() { echo -e "${YELLOW}[IAC-Ansible WARN]${NC} $*"; }
err()  { echo -e "${RED}[IAC-Ansible ERROR]${NC} $*" >&2; }

# --- Cleanup on exit ---
cleanup() {
    rm -f "${LOCK_FILE}"
    rm -rf "${LOCK_FILE}.d"
}
trap cleanup EXIT

# --- Pre-flight checks ---
if [ "$(id -u)" -ne 0 ]; then
    err "This script must be run as root"
    exit 1
fi

# Prevent concurrent execution (atomic lock via mkdir)
if ! mkdir "${LOCK_FILE}.d" 2>/dev/null; then
    LOCK_PID=$(cat "${LOCK_FILE}" 2>/dev/null || true)
    if [ -n "${LOCK_PID}" ] && kill -0 "${LOCK_PID}" 2>/dev/null; then
        err "Another instance is already running (PID: ${LOCK_PID})"
        exit 1
    fi
    warn "Stale lock found, reclaiming"
    rm -rf "${LOCK_FILE}.d"
    mkdir "${LOCK_FILE}.d"
fi
echo $$ > "${LOCK_FILE}"

# Idempotency: skip if already bootstrapped (force with FORCE=1)
if [ -f "${MARKER_FILE}" ] && [ "${FORCE:-0}" != "1" ]; then
    log "System already bootstrapped (${MARKER_FILE} exists)"
    log "To force re-bootstrap: FORCE=1 $0"
    exit 0
fi

log "=== IAC-Ansible Bootstrap Installer ==="
log "Repository: ${REPO_URL}"
log "Branch:     ${BRANCH}"
log "Playbook:   ${PLAYBOOK}"
log "Schedule:   ${SCHEDULE}"
if [ -n "${IAC_HOSTNAME}" ]; then
    log "Hostname:   ${IAC_HOSTNAME} (will be set before ansible-pull)"
fi
log ""

# --- Validate environment ---
validate_environment() {
    # Check systemd is available
    if ! command -v systemctl &>/dev/null; then
        err "systemd is required but not found (systemctl not in PATH)"
        exit 1
    fi

    # Check git connectivity to repo
    if command -v git &>/dev/null; then
        if ! git ls-remote --exit-code "${REPO_URL}" &>/dev/null; then
            warn "Cannot reach repository: ${REPO_URL} (will retry after git install)"
        fi
    fi
}

# --- Detect OS ---
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_ID="${ID}"
        OS_VERSION="${VERSION_ID:-unknown}"
        OS_FAMILY=""

        case "${OS_ID}" in
            ubuntu|debian|linuxmint)
                OS_FAMILY="debian"
                ;;
            centos|rhel|rocky|almalinux|fedora|ol)
                OS_FAMILY="redhat"
                ;;
            *)
                err "Unsupported distribution: ${OS_ID}"
                exit 1
                ;;
        esac
    else
        err "Cannot detect OS: /etc/os-release not found"
        exit 1
    fi

    log "Detected OS: ${OS_ID} ${OS_VERSION} (family: ${OS_FAMILY})"
}

# --- Install Ansible ---
install_ansible_debian() {
    log "Installing Ansible via apt..."
    export DEBIAN_FRONTEND=noninteractive

    apt-get update -qq
    apt-get install -y -qq git curl

    if [ "${OS_ID}" = "ubuntu" ]; then
        # Register Ansible PPA with the signed-by keyring pattern.
        # Must match roles/ansible_pull/tasks/debian.yml byte-for-byte so
        # the role stays idempotent and apt never sees two registrations
        # with different Signed-By values (noble fails hard on that).
        mkdir -p /etc/apt/keyrings
        local keyring="/etc/apt/keyrings/ansible-ppa.asc"
        if [ ! -s "${keyring}" ]; then
            curl -fsSL \
                "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x6125E2A8C77F2818FB7BD15B93C4A3FD7BB9C367" \
                -o "${keyring}"
            chmod 0644 "${keyring}"
        fi
        # Purge any legacy add-apt-repository registration (inline Signed-By)
        rm -f /etc/apt/sources.list.d/ansible-ubuntu-ansible-*.sources
        local codename
        codename="$(. /etc/os-release && echo "${VERSION_CODENAME}")"
        cat > /etc/apt/sources.list.d/ansible-ppa.list <<EOF
deb [signed-by=${keyring}] https://ppa.launchpadcontent.net/ansible/ansible/ubuntu ${codename} main
EOF
        apt-get update -qq
    fi

    apt-get install -y -qq ansible

    local ansible_ver
    ansible_ver=$(ansible --version 2>/dev/null | head -1)
    log "Ansible installed: ${ansible_ver}"
}

install_ansible_redhat() {
    log "Installing Ansible via yum/dnf..."

    if command -v dnf &>/dev/null; then
        dnf install -y epel-release
        dnf install -y ansible git curl
    else
        yum install -y epel-release
        yum install -y ansible git curl
    fi

    local ansible_ver
    ansible_ver=$(ansible --version 2>/dev/null | head -1)
    log "Ansible installed: ${ansible_ver}"
}

# --- Configure inventory hostname (opt-in via IAC_HOSTNAME) ---
# Mirrors roles/common/tasks/hostname.yml so ansible-pull finds the matching
# inventory entry on first run. Idempotent: re-running with the same value
# is a no-op.
configure_hostname() {
    if [ -z "${IAC_HOSTNAME}" ]; then
        return 0
    fi

    local current short_host
    current=$(hostname -f 2>/dev/null || hostname)
    short_host="${IAC_HOSTNAME%%.*}"

    if [ "${current}" = "${IAC_HOSTNAME}" ]; then
        log "Hostname already set to ${IAC_HOSTNAME}"
    else
        log "Setting hostname to ${IAC_HOSTNAME} (was: ${current})"
        hostnamectl set-hostname "${IAC_HOSTNAME}"
    fi

    # /etc/hosts: keep the 127.0.1.1 mapping in sync
    if grep -qE '^127\.0\.1\.1[[:space:]]' /etc/hosts; then
        sed -i "s|^127\.0\.1\.1[[:space:]].*|127.0.1.1 ${IAC_HOSTNAME} ${short_host}|" /etc/hosts
    else
        echo "127.0.1.1 ${IAC_HOSTNAME} ${short_host}" >> /etc/hosts
    fi

    # Prevent cloud-init from overwriting the hostname on next boot
    if [ -f /etc/cloud/cloud.cfg ]; then
        if grep -qE '^#?preserve_hostname:' /etc/cloud/cloud.cfg; then
            sed -i 's|^#\?preserve_hostname:.*|preserve_hostname: true|' /etc/cloud/cloud.cfg
        else
            echo "preserve_hostname: true" >> /etc/cloud/cloud.cfg
        fi
    fi
}

# --- Configure vault credentials (opt-in via environment variables) ---
# Deploys credential files required by the secrets role.
# All files are root-only (0400) and placed outside the git working directory.
configure_vault_credentials() {
    local changed=false

    # Ansible Vault password → /etc/ansible/vault-password
    if [ -n "${VAULT_PASSWORD}" ]; then
        log "Deploying Ansible Vault password to /etc/ansible/vault-password"
        mkdir -p /etc/ansible
        printf '%s' "${VAULT_PASSWORD}" > /etc/ansible/vault-password
        chmod 0400 /etc/ansible/vault-password
        changed=true
    fi

    # HashiCorp Vault AppRole credentials → /etc/iac-ansible/
    if [ -n "${VAULT_ROLE_ID}" ]; then
        log "Deploying HashiCorp Vault AppRole credentials to /etc/iac-ansible/"
        mkdir -p /etc/iac-ansible
        printf '%s' "${VAULT_ROLE_ID}" > /etc/iac-ansible/vault-role-id
        chmod 0400 /etc/iac-ansible/vault-role-id

        if [ -n "${VAULT_SECRET_ID}" ]; then
            printf '%s' "${VAULT_SECRET_ID}" > /etc/iac-ansible/vault-secret-id
            chmod 0400 /etc/iac-ansible/vault-secret-id
        fi
        changed=true
    fi

    if [ "${changed}" = "true" ]; then
        log "Vault credentials deployed successfully"
    fi
}

# --- Setup directories ---
setup_directories() {
    log "Creating directories..."
    mkdir -p "${WORKDIR}"
    mkdir -p "$(dirname "${LOG_FILE}")"
    chmod 750 "$(dirname "${LOG_FILE}")"
}

# --- Configure systemd service and timer ---
setup_systemd() {
    log "Configuring systemd timer for ansible-pull..."

    # Build ansible-pull command with optional vault flag
    local pull_cmd="/usr/bin/ansible-pull"
    pull_cmd+=" --url ${REPO_URL}"
    pull_cmd+=" --checkout ${BRANCH}"
    pull_cmd+=" --directory ${WORKDIR}"
    pull_cmd+=" --inventory ${INVENTORY}"
    pull_cmd+=" --full"
    if [ -n "${VAULT_PASSWORD}" ]; then
        pull_cmd+=" --vault-password-file /etc/ansible/vault-password"
    fi
    pull_cmd+=" ${PLAYBOOK}"

    cat > /etc/systemd/system/ansible-pull.service << SVCEOF
[Unit]
Description=IAC-Ansible Pull Configuration from Git
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=${pull_cmd}
StandardOutput=append:${LOG_FILE}
StandardError=append:${LOG_FILE}
TimeoutStartSec=1800
Environment="ANSIBLE_LOG_PATH=${LOG_FILE}"
Environment="HOME=/root"

[Install]
WantedBy=multi-user.target
SVCEOF

    cat > /etc/systemd/system/ansible-pull.timer << TMREOF
[Unit]
Description=IAC-Ansible Pull Timer

[Timer]
OnCalendar=${SCHEDULE}
RandomizedDelaySec=${RANDOM_DELAY}
Persistent=true
AccuracySec=60

[Install]
WantedBy=timers.target
TMREOF

    # Logrotate
    cat > /etc/logrotate.d/ansible-pull << LREOF
${LOG_FILE} {
    weekly
    rotate 4
    compress
    delaycompress
    missingok
    notifempty
    create 0640 root root
}
LREOF

    systemctl daemon-reload
    systemctl enable --now ansible-pull.timer
    log "Timer enabled: $(systemctl is-active ansible-pull.timer)"
}

# --- Run initial pull ---
run_initial_pull() {
    log "Running initial ansible-pull (this may take a few minutes)..."
    local rc=0
    ansible-pull \
        --url "${REPO_URL}" \
        --checkout "${BRANCH}" \
        --directory "${WORKDIR}" \
        --full \
        "${PLAYBOOK}" > >(tee -a "${LOG_FILE}") 2>&1 || rc=$?

    if [ "${rc}" -eq 0 ]; then
        log "Initial pull completed successfully"
    else
        warn "Initial pull failed (exit code ${rc}). Check ${LOG_FILE} for details."
    fi
}

# --- Main ---
main() {
    validate_environment
    detect_os
    configure_hostname

    case "${OS_FAMILY}" in
        debian) install_ansible_debian ;;
        redhat) install_ansible_redhat ;;
    esac

    configure_vault_credentials
    setup_directories
    setup_systemd
    run_initial_pull

    # Mark as bootstrapped
    echo "bootstrapped=$(date -u '+%Y-%m-%dT%H:%M:%SZ') branch=${BRANCH}" > "${MARKER_FILE}"
    chmod 600 "${MARKER_FILE}"

    log ""
    log "=== Bootstrap Complete ==="
    log "ansible-pull timer is active and will check for updates."
    log "Schedule: ${SCHEDULE}"
    log "Log file: ${LOG_FILE}"
    log ""
    log "Manual commands:"
    log "  systemctl start ansible-pull     # Trigger immediate pull"
    log "  systemctl status ansible-pull    # Check last run status"
    log "  journalctl -u ansible-pull       # View service logs"
    log "  tail -f ${LOG_FILE}              # Follow ansible log"
}

main "$@"

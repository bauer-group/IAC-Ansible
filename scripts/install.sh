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
LOG_FILE="${LOG_FILE:-/var/log/ansible/ansible-pull.log}"
SCHEDULE="${SCHEDULE:-*-*-* 02:00:00}"
RANDOM_DELAY="${RANDOM_DELAY:-900}"
LOCK_FILE="/var/run/iac-ansible-install.lock"
MARKER_FILE="/etc/iac-ansible-bootstrapped"

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
}
trap cleanup EXIT

# --- Pre-flight checks ---
if [ "$(id -u)" -ne 0 ]; then
    err "This script must be run as root"
    exit 1
fi

# Prevent concurrent execution
if [ -f "${LOCK_FILE}" ]; then
    LOCK_PID=$(cat "${LOCK_FILE}" 2>/dev/null || true)
    if [ -n "${LOCK_PID}" ] && kill -0 "${LOCK_PID}" 2>/dev/null; then
        err "Another instance is already running (PID: ${LOCK_PID})"
        exit 1
    fi
    warn "Stale lock file found, removing"
    rm -f "${LOCK_FILE}"
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
log ""

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
    apt-get install -y -qq software-properties-common git curl

    if [ "${OS_ID}" = "ubuntu" ]; then
        apt-add-repository -y ppa:ansible/ansible 2>/dev/null || true
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

    cat > /etc/systemd/system/ansible-pull.service << SVCEOF
[Unit]
Description=IAC-Ansible Pull Configuration from Git
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/ansible-pull \\
  --url ${REPO_URL} \\
  --checkout ${BRANCH} \\
  --directory ${WORKDIR} \\
  --full \\
  ${PLAYBOOK}
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
    if ansible-pull \
        --url "${REPO_URL}" \
        --checkout "${BRANCH}" \
        --directory "${WORKDIR}" \
        --full \
        "${PLAYBOOK}" 2>&1 | tee -a "${LOG_FILE}"; then
        log "Initial pull completed successfully"
    else
        warn "Initial pull completed with warnings. Check ${LOG_FILE} for details."
    fi
}

# --- Main ---
main() {
    detect_os

    case "${OS_FAMILY}" in
        debian) install_ansible_debian ;;
        redhat) install_ansible_redhat ;;
    esac

    setup_directories
    setup_systemd
    run_initial_pull

    # Mark as bootstrapped
    echo "bootstrapped=$(date -u '+%Y-%m-%dT%H:%M:%SZ') branch=${BRANCH}" > "${MARKER_FILE}"
    chmod 644 "${MARKER_FILE}"

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

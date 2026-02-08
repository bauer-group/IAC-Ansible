#!/bin/bash
# =============================================================================
# IAC-Ansible: Push Update Trigger
# =============================================================================
# Remotely trigger ansible-pull on specified hosts via SSH.
#
# Usage:
#   ./scripts/push-update.sh <host-or-pattern>
#   ./scripts/push-update.sh 0046-20.cloud.bauer-group.com
#   ./scripts/push-update.sh all
#
# This is the "push" alternative to the scheduled pull model.
# =============================================================================

set -euo pipefail

INVENTORY="${INVENTORY:-inventory/production/hosts.yml}"

if [ $# -eq 0 ]; then
    echo "Usage: $0 <host-pattern>"
    echo ""
    echo "Examples:"
    echo "  $0 all                                    # All hosts"
    echo "  $0 0046-20.cloud.bauer-group.com          # Specific host"
    echo "  $0 '*.bauer-group.com'                    # Wildcard"
    echo "  $0 auto_update                            # Group"
    exit 1
fi

TARGET="$1"
shift

echo "[IAC-Ansible] Triggering ansible-pull on: ${TARGET}"
echo "[IAC-Ansible] Inventory: ${INVENTORY}"
echo ""

ansible -i "${INVENTORY}" "${TARGET}" \
    -m ansible.builtin.systemd \
    -a "name=ansible-pull.service state=started" \
    --become \
    "$@"

echo ""
echo "[IAC-Ansible] Push update triggered successfully on: ${TARGET}"
echo "[IAC-Ansible] Hosts will pull and apply latest configuration from Git."

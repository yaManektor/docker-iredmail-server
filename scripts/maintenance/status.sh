#!/usr/bin/env bash
set -euo pipefail

if [ -d /opt/iredmail/custom/nginx ]; then
    BASE="/opt/iredmail/custom/nginx"
else
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    BASE="${SCRIPT_DIR}/../../data/custom/nginx"
fi

FLAG="${BASE}/maintenance.flag"

if [ -f "${FLAG}" ]; then
    echo "🛠️ Maintenance mode: ON"
    echo "   Flag file: ${FLAG}"
else
    echo "✅ Maintenance mode: OFF"
    echo "   Flag file (expected): ${FLAG}"
fi

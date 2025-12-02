#!/usr/bin/env bash
set -euo pipefail

if [ -d /opt/iredmail/custom/nginx ]; then
    BASE="/opt/iredmail/custom/nginx"
    IN_CONTAINER=1
else
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    BASE="${SCRIPT_DIR}/../../data/custom/nginx"
    IN_CONTAINER=0

    ENV_FILE="${SCRIPT_DIR}/../../.env"
    if [ -f "${ENV_FILE}" ]; then
        set -a
        . "${ENV_FILE}"
        set +a
    fi
fi

FLAG="${BASE}/maintenance.flag"

safe_mkdir() {
    local dir="$1"
    if ! mkdir -p "${dir}" 2>/dev/null; then
        sudo mkdir -p "${dir}"
    fi
}

safe_touch() {
    local file="$1"
    if ! touch "${file}" 2>/dev/null; then
        sudo touch "${file}"
    fi
}

safe_rm() {
    local file="$1"
    if ! rm -f "${file}" 2>/dev/null; then
        sudo rm -f "${file}"
    fi
}

run_in_container() {
    local cmd="$1"
    if [ "${IN_CONTAINER}" -eq 1 ]; then
        eval "${cmd}"
    else
        if [ -n "${IREDMAIL_CONTAINER_NAME:-}" ]; then
            local DOCKER_BIN="docker"
            if ! ${DOCKER_BIN} exec "${IREDMAIL_CONTAINER_NAME}" true >/dev/null 2>&1; then
                DOCKER_BIN="sudo docker"
            fi
            ${DOCKER_BIN} exec "${IREDMAIL_CONTAINER_NAME}" bash -c "${cmd}"
        else
            echo "⚠️ Cannot execute command: IREDMAIL_CONTAINER_NAME is not specified."
            return 1
        fi
    fi
}

stop_dovecot() {
    echo "🛑 Stopping Dovecot..."
    if run_in_container "/etc/init.d/dovecot stop" 2>/dev/null; then
        echo "✅ Dovecot stopped"
    else
        echo "❌ Failed to stop Dovecot (might be already stopped)"
    fi
}

start_dovecot() {
    echo "➡️ Starting Dovecot..."
    if run_in_container "/etc/init.d/dovecot start" 2>/dev/null; then
        echo "✅ Dovecot started"
    else
        echo "❌ Failed to start Dovecot"
    fi
}

hold_postfix_queue() {
    echo "⏸️ Holding Postfix queue..."
    if run_in_container "postsuper -h ALL" 2>/dev/null; then
        echo "✅ Postfix queue on hold"
    else
        echo "❌ Failed to hold Postfix queue"
    fi
}

release_postfix_queue() {
    echo "➡️ Releasing Postfix queue..."
    if run_in_container "postsuper -H ALL" 2>/dev/null; then
        echo "✅ Postfix queue released"
    else
        echo "❌ Failed to release Postfix queue"
    fi
}

toggle_flag() {
    if [ "${IN_CONTAINER}" -eq 1 ]; then
        mkdir -p "${BASE}"
        if [ -f "${FLAG}" ]; then
            rm -f "${FLAG}"
            echo "✅ Maintenance mode: OFF"
        else
            touch "${FLAG}"
            echo "🛠️ Maintenance mode: ON"
        fi
    else
        safe_mkdir "${BASE}"
        if [ -f "${FLAG}" ]; then
            safe_rm "${FLAG}"
            echo "✅ Maintenance mode: OFF"
        else
            safe_touch "${FLAG}"
            echo "🛠️ Maintenance mode: ON"
        fi
    fi
}

reload_nginx() {
    echo "🔄 Testing Nginx configuration..."

    if ! run_in_container "nginx -t" >/dev/null 2>&1; then
        echo "❌ Nginx config test failed"
        exit 1
    fi

    if run_in_container "nginx -s reload" >/dev/null 2>&1; then
        echo "♻️ Nginx reloaded"
    else
        echo "❌ Failed to reload Nginx"
        exit 1
    fi
}

toggle_flag

if [ -f "${FLAG}" ]; then
    MAINTENANCE_ON=1
else
    MAINTENANCE_ON=0
fi

if [ ${MAINTENANCE_ON} -eq 1 ]; then
    stop_dovecot
    hold_postfix_queue
else
    release_postfix_queue
    start_dovecot
fi

reload_nginx

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
    if [ "${IN_CONTAINER}" -eq 1 ]; then
        if nginx -t >/dev/null 2>&1; then
            nginx -s reload
            echo "♻️ Nginx reloaded inside container"
        else
            echo "❌ Nginx config test failed inside container"
            exit 1
        fi
    else
        if [ -n "${IREDMAIL_CONTAINER_NAME:-}" ]; then
            DOCKER_BIN="docker"

            if ! ${DOCKER_BIN} exec "${IREDMAIL_CONTAINER_NAME}" nginx -t >/dev/null 2>&1; then
                DOCKER_BIN="sudo docker"
            fi

            if ${DOCKER_BIN} exec "${IREDMAIL_CONTAINER_NAME}" nginx -t >/dev/null 2>&1; then
                ${DOCKER_BIN} exec "${IREDMAIL_CONTAINER_NAME}" nginx -s reload
                echo "♻️ Nginx reloaded in container: ${IREDMAIL_CONTAINER_NAME}"
            else
                echo "❌ Nginx config test failed in container: ${IREDMAIL_CONTAINER_NAME}"
                exit 1
            fi
        else
            echo "⚠️ Nginx was not reloaded because IREDMAIL_CONTAINER_NAME is not specified."
        fi
    fi
}

toggle_flag
reload_nginx

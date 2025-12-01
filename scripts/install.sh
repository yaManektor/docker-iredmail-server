#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${BASE_DIR}/.env"

error() {
    echo "❌ $*" >&2
    exit 1
}

safe_rsync() {
    if ! rsync -a "$1" "$2" 2>/dev/null; then
        sudo rsync -a "$1" "$2"
    fi
}

if [ ! -f "${ENV_FILE}" ]; then
    error ".env file not found at ${ENV_FILE}"
fi

set -a
. "${ENV_FILE}"
set +a

: "${DATA_DIR:?DATA_DIR is not set in .env}"

COMPOSE_CMD=()
if command -v docker-compose >/dev/null 2>&1; then
    COMPOSE_CMD=(docker-compose)
elif command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    COMPOSE_CMD=(docker compose)
else
    error "docker compose or docker-compose not found"
fi


echo "▶ Starting containers to initialize volumes..."
(
    cd "${BASE_DIR}"

    if ! "${COMPOSE_CMD[@]}" up -d; then
        if command -v sudo >/dev/null 2>&1; then
            sudo "${COMPOSE_CMD[@]}" up -d
        else
            error "Failed to run docker compose (no sudo available and non-root execution failed)."
        fi
    fi
)
echo "✅ Containers started."


SRC_CUSTOM="${BASE_DIR}/custom"
DST_CUSTOM="${DATA_DIR}/custom"

if [ ! -d "${SRC_CUSTOM}" ]; then
    echo "ℹ️ No ./custom directory found at ${SRC_CUSTOM}, nothing to copy."
    exit 0
fi

echo "▶ Syncing ${SRC_CUSTOM} → ${DST_CUSTOM} ..."
safe_rsync "${SRC_CUSTOM}/" "${DST_CUSTOM}/"

echo "✅ Custom configuration synced to ${DST_CUSTOM}"
echo "🎉 Install finished."


if [ -n "${IREDMAIL_CONTAINER_NAME:-}" ]; then
    echo "▶ Restarting container ${IREDMAIL_CONTAINER_NAME} to apply custom configurations..."

    DOCKER_BIN="docker"
    if ! ${DOCKER_BIN} ps >/dev/null 2>&1; then
        DOCKER_BIN="sudo docker"
    fi

    if ! ${DOCKER_BIN} restart "${IREDMAIL_CONTAINER_NAME}" >/dev/null 2>&1; then
        error "Failed to restart container ${IREDMAIL_CONTAINER_NAME}"
    fi

    echo "✅ Container ${IREDMAIL_CONTAINER_NAME} restarted."
else
    echo "ℹ️ IREDMAIL_CONTAINER_NAME is not set in .env, skipping container restart."
fi

echo "🎉 Install finished."

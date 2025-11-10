#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"

if [[ -f "$ENV_FILE" ]]; then
  set -a
  source "$ENV_FILE"
  set +a
else
  echo "Fail: $ENV_FILE not found" >&2
  exit 1
fi

mkdir -p "$LOG_DIR"

LOG_FILE="${LOG_DIR}/backup_$(date +%F_%H%M%S).log"
exec >> "$LOG_FILE" 2>&1

ts="$(date +%F_%H%M%S)"
dst="${BACKUP_ROOT}/${ts}"
mkdir -p "${dst}"

log() { echo "[$(date +%F\ %T)] $*"; }

log "Dump MariaDB…"
DBS=(vmail iredapd iredadmin amavisd roundcubemail)
docker exec "${CONTAINER}" bash -lc '
set -e
mkdir -p /tmp/dumps
for db in vmail iredapd iredadmin amavisd roundcubemail; do
  mysqldump --single-transaction --routines ${db} > "/tmp/dumps/${db}.sql"
done
'
mkdir -p "${dst}/db"
for db in "${DBS[@]}"; do
  docker cp "${CONTAINER}:/tmp/dumps/${db}.sql" "${dst}/db/${db}.sql" || log "⚠️ missing dump for ${db}"
done
docker exec "${CONTAINER}" bash -lc 'rm -rf /tmp/dumps'


log "Copy files…"
mkdir -p "${dst}/files"
rsync -aHAX --delete --info=stats1,progress2 "${DATA_DIR}/mail/" "${dst}/files/mail/"
rsync -a --delete "${DATA_DIR}/ssl/" "${dst}/files/ssl/"
rsync -a --delete "${DATA_DIR}/custom/" "${dst}/files/custom/" || true
# rsync -a --delete "${DATA_DIR}/sa_rules/" "${dst}/files/sa_rules/" || true


log "Compress…"
if tar -C "${BACKUP_ROOT}" \
    --acls --xattrs --numeric-owner \
    --sort=name \
    -I 'zstd -T0 -19 -q' \
    -cpf "${BACKUP_ROOT}/backup_${ts}.tar.zst" \
    "${ts}";
then
  rm -rf "${dst}"
else
  log "⚠️ Compression failed, backup directory left at ${dst}"
fi


log "Prune old backups…"
find "${BACKUP_ROOT}" -maxdepth 1 -type f -name 'backup_*.tar.zst' -mtime +${KEEP_DAYS} -print -delete

log "Done."

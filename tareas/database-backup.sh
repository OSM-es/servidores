#!/bin/bash

##############################
## POSTGRESQL BACKUP CONFIG ##
##############################

# Username to connect to database as.
USERNAME=tm

# Database to backup.
DATABASE=tasking-manager

# This dir will be created if it doesn't exist. This must be writable by the user the script is running as.
BACKUP_DIR=/home/tm/backups

# Location of the tasking-manager. It must be a git repository.
TM_DIR=/home/tm/tasking-manager

# Number of days to keep daily backups
DAYS_TO_KEEP=15

##############################

VERSION=$(git -C "${TM_DIR}" describe --tags)
FILENAME="$(date +\%Y\%m\%d-\%H\%M\%S).${DATABASE}-${VERSION}"

if ! mkdir -p "${BACKUP_DIR}"; then
  echo "Cannot create backup directory. Go and fix it!" 1>&2
  exit 1;
fi;

set -o pipefail
if ! docker exec -i postgresql pg_dump -Fp -U "$USERNAME" "${DATABASE}" | gzip > "${BACKUP_DIR}"/"${FILENAME}.sql.gz.in_progress"; then
  echo "[!!ERROR!!] Failed to produce plain backup database ${DATABASE}" 1>&2
else
  mv "${BACKUP_DIR}"/"${FILENAME}.sql.gz.in_progress" "${BACKUP_DIR}"/"${FILENAME}.sql.gz"
fi
set +o pipefail

# Generate checksum
sha256sum "${BACKUP_DIR}"/"${FILENAME}.sql.gz" > "${BACKUP_DIR}"/"${FILENAME}.sql.gz.sha256"

# Delete older backups
find "${BACKUP_DIR}" -maxdepth 1 -mtime +${DAYS_TO_KEEP} -delete -printf "Deleted backup file: %f\n"

exit 0

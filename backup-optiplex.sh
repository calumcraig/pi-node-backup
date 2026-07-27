#!/bin/bash

set -euo pipefail

export RESTIC_PASSWORD_FILE=/home/calum/.restic-password
RESTIC_REPOSITORY=/srv/backup/restic

echo "Starting backup: $(date)"

ssh -i /home/calum/.ssh/id_ed25519_backup calum@optiplex.local \
  "sudo /usr/local/bin/backup-databases.sh"

echo "Database dumps complete: $(date)"

rsync -az --delete-delay \
  --rsync-path="sudo rsync" \
  -e "ssh -i /home/calum/.ssh/id_ed25519_backup" \
  calum@optiplex.local:/srv/backup-staging/ \
  /srv/backup/incoming/

rsync -az --delete-delay \
  --rsync-path="sudo rsync" \
  --exclude='jellyfin/config/metadata/' \
  --exclude='jellyfin/config/log/' \
  -e "ssh -i /home/calum/.ssh/id_ed25519_backup" \
  calum@optiplex.local:/srv/docker/ \
  /srv/backup/incoming/docker/

rsync -az --delete-delay \
  --rsync-path="sudo rsync" \
  --exclude='postgres-nextcloud/' \
  --exclude='postgres-immich/' \
  -e "ssh -i /home/calum/.ssh/id_ed25519_backup" \
  calum@optiplex.local:/srv/data/ \
  /srv/backup/incoming/data/

echo "Application data backup complete: $(date)"

rsync -az --delete-delay \
  --rsync-path="sudo rsync" \
  -e "ssh -i /home/calum/.ssh/id_ed25519_backup" \
  calum@optiplex.local:/srv/storage/immich/ \
  /srv/backup/incoming/immich/

echo "Immich library backup complete: $(date)"

echo "Starting Restic backup: $(date)"

restic -r "$RESTIC_REPOSITORY" backup /srv/backup/incoming

echo "Restic backup complete: $(date)"

echo "Applying Restic retention policy: $(date)"

restic -r "$RESTIC_REPOSITORY" forget \
  --keep-daily 7 \
  --keep-weekly 4

if [ "$(date +%u)" -eq 7 ]; then
    echo "Running weekly Restic prune: $(date)"

    restic -r "$RESTIC_REPOSITORY" prune

    echo "Restic prune complete: $(date)"
fi

echo "Restic retention complete: $(date)"

echo "Backup completed successfully: $(date)"

sudo shutdown -h now

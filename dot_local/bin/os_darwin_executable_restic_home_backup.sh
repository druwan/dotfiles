#!/usr/bin/env bash
# Store password in Keychain first
# security add-generic-password -a "$USER" -s "restic-mba" -w

export RESTIC_REPOSITORY="sftp:truenas_admin@192.168.1.83:/mnt/main/backups/mba"
export RESTIC_PASSWORD_COMMAND="security find-generic-password -a $USER -s restic-mba -w"

restic backup \
  $HOME/Documents \
  $HOME/Projects \
  $HOME/.ssh \
  $HOME/.aws \
  --tag "home" \
  --verbose

echo "Pruning old backups..."
restic forget \
  --keep-daily 7 \
  --keep-weekly 4 \
  --keep-monthly 12 \
  --prune \
  --tag "home"

echo "Finished $(date +'%Y-%m-%d %H:%M:%S')"

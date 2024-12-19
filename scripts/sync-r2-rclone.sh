#!/bin/bash

# Check if the /data directory exists. If not, create it.
if [ ! -d "/data" ]; then
  mkdir -p /data
fi

# Check if the /root/.config/rclone directory exists. If not, create it.
if [ ! -d "/root/.config/rclone" ]; then
  mkdir -p /root/.config/rclone
fi

chmod 700 /root/.config/rclone

cat << EOF > /root/.config/rclone/rclone.conf
[Cloudflare]
type = s3
provider = Cloudflare
access_key_id = $CF_ACCESS_KEY
secret_access_key = $CF_ACCESS_KEY_SECRET
region = auto
endpoint = $CF_R2_ENDPOINT
acl = private
no_check_bucket = true
EOF
chmod 600 /root/.config/rclone/rclone.conf

REMOTE_NAME="Cloudflare"
REMOTE_PATH="vaultwarden-data/data"

LAST_MODIFIED=$(find /data -type f -exec stat -c %Y {} \; | sort -n | tail -1)

while true; do
  # Get the current modification time of the files in the /data directory
  CURRENT_MODIFIED=$(find /data -type f -exec stat -c %Y {} \; | sort -n | tail -1)

  # Check if the /data directory has been modified since the last sync
  if [ $CURRENT_MODIFIED -gt $LAST_MODIFIED ]; then
    if [ "$R2_DATA_SYNC_LOG" = "true" ]; then
      rclone sync ./data $REMOTE_NAME:$REMOTE_PATH
      echo "Sync completed successfully!"
    else
      rclone sync ./data $REMOTE_NAME:$REMOTE_PATH
    fi
    LAST_MODIFIED=$CURRENT_MODIFIED
  else
    if [ "$R2_DATA_SYNC_LOG" = "true" ]; then
      echo "Sync skipped, no changes detected."
    fi
  fi

  sleep 60

  # Add a check to see if the vaultwarden.log file is being written to
  if [ -f "/data/vaultwarden.log" ]; then
    if [ $(tail -c 1 /data/vaultwarden.log) != "" ]; then
      # If the file is being written to, skip the sync operation
      if [ "$R2_DATA_SYNC_LOG" = "true" ]; then
        echo "Sync skipped, vaultwarden.log is being written to."
      fi
    fi
  fi
done

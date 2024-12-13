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

# Get the modification time of the /data directory
LAST_MODIFIED=$(stat -c %Y /data)

# Check if the /data directory has been modified since the last sync
if [ -z "$LAST_MODIFIED" ]; then
  echo "Error: Unable to get modification time of /data directory."
  exit 1
fi

while true; do
  # Check if the /data directory has been modified
  CURRENT_TIME=$(date +%s)
  if [ $((CURRENT_TIME - LAST_MODIFIED)) -gt 60 ]; then
    rclone sync ./data $REMOTE_NAME:$REMOTE_PATH
    echo "Sync completed successfully!"
    LAST_MODIFIED=$(stat -c %Y /data)
  else
    echo "Sync skipped, no changes detected."
    sleep 60
  fi
done

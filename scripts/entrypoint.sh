#!/bin/bash

# Set up swap space
SWAPFILE="/swapfile"

if [ ! -f "$SWAPFILE" ]; then
    echo "Creating swap file..."
    dd if=/dev/zero of=$SWAPFILE bs=1M count=256
    chmod 600 $SWAPFILE
    mkswap $SWAPFILE
    swapon $SWAPFILE
else
    echo "Swap file already exists. Skipping creation."
fi

# Configure Rclone
mkdir -p /root/.config/rclone
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

mkdir -p /data
chmod 700 /data

REMOTE_NAME="Cloudflare"
REMOTE_PATH="vaultwarden-data/data"

rclone copy $REMOTE_NAME:$REMOTE_PATH ./data

# Run the original entrypoint
exec "$@"
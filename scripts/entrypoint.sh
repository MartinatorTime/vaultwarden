#!/bin/bash

# Set up swap space
SWAPFILE="/.fly-upper-layer/swapfile"

if [[ "$FLY_SWAP" == "true" ]] && [ ! -f "$SWAPFILE" ]; then
    echo "Creating swap file..."
    dd if=/dev/zero of=$SWAPFILE bs=1M count=256
    chmod 600 $SWAPFILE
    mkswap $SWAPFILE
    swapon $SWAPFILE
else
    echo "Swap file already exists or FLY_SWAP is not set to true. Skipping creation."
fi

if [[ "$SYNC_DATA_CLOUDFLARE_R2" == "true" ]]; then
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
REMOTE_PATH="vaultwarden-data"

rclone copy $REMOTE_NAME:$REMOTE_PATH ./data
echo "Data synced from R2"
else
echo "Skipping data sync from R2"
fi

if [[ "$FAIL2BAN" == "true" ]]; then
    if ! fail2ban-client status >/dev/null 2>&1; then
        echo "Starting Fail2Ban Server"
        rm -f /var/run/fail2ban/fail2ban.pid
        fail2ban-client start
    else
        echo "Fail2Ban Server is already running"
    fi
else
    echo "Skipped Fail2Ban Server"
fi
# Run the original entrypoint
exec "$@"

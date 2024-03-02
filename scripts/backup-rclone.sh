#!/bin/bash

# Ensure the directory exists and has the correct permissions
mkdir -p /root/.config/rclone
chmod 700 /root/.config/rclone

# Generate or modify rclone.conf
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

sqlite3 /data/db.sqlite3 '.backup /data/db.bak'
tar -czf /backup.tar.gz /data

# Encrypt backup and Upload to Cloudflare R2
echo "$PASS" | gpg --batch --yes --passphrase-fd  0 --cipher-algo AES256 --symmetric backup.tar.gz

# Define the remote name and path in Cloudflare R2 where you want to store the backup
FILE_NAME="DATA-backup-$(date +'%d_%m_%Y-%H_%M').tar.gz.gpg"
REMOTE_NAME="Cloudflare"
REMOTE_PATH="vaultwarden/DATA"

mv backup.tar.gz.gpg $FILE_NAME
# Perform the backup
rclone copy ./$FILE_NAME $REMOTE_NAME:$REMOTE_PATH

# Remove local files
rm *.tar.gz.gpg
rm *.tar.gz
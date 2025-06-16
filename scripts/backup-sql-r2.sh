#!/bin/bash

# Ensure the directory exists and has the correct permissions
mkdir -p /root/.config/rclone
chmod 700 /root/.config/rclone

# Configure Rclone
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

# Dump PostgreSQL database
filename="SQL_BACKUP.sql"
/usr/lib/postgresql/16/bin/pg_dump -Fc -O -x -d $DATABASE -f /tmp/$filename >/dev/null

# Encrypt SQL file
echo "$PASS" | gpg --batch --yes --passphrase-fd 0 --cipher-algo AES256 --symmetric /tmp/$filename >/dev/null

# Upload to Cloudflare R2
FILE_NAME="sql-backup-$(date +'%d_%m_%Y-%H_%M').sql.gpg"
REMOTE_NAME="Cloudflare"
REMOTE_PATH="vaultwarden/SQL"

mv /tmp/SQL_BACKUP.sql.gpg $FILE_NAME
rclone copy ./$FILE_NAME $REMOTE_NAME:$REMOTE_PATH

# Remove local files
rm $FILE_NAME
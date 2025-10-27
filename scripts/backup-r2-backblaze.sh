#!/bin/bash

sqlite3 /data/db.sqlite3 '.backup /data/db.bak'
tar -czf /backup.tar.gz /data

# Encrypt File and Upload to Backblaze B2
gpg --batch --yes --passphrase "$PASS" --cipher-algo AES256 --symmetric backup.tar.gz

# Authorize with Backblaze B2
b2 account authorize "$B2_APPLICATION_KEY_ID" "$B2_APPLICATION_KEY"

# Upload the encrypted backup file to B2
FILE_NAME="DATA-backup-$(date +'%d_%m_%Y-%H_%M').tar.gz.gpg"
b2 file upload $B2_BUCKET backup.tar.gz.gpg $FILE_NAME

# Remove local files
rm *.tar.gz.gpg
rm *.tar.gz
W
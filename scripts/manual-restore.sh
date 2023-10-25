#!/usr/bin/env bash

rm -rf /data

# curl:
# -O: Use name provided from endpoint
# -J: "Content Disposition" header, in this case "attachment"
# -L: Follow links, we actually get forwarded in this request
# -H "Accept: application/octet-stream": Tells api we want to dl the full binary
curl -O -J -L -H "Accept: application/octet-stream" "$API_URL/releases/assets/$ASSET_ID"

# Decrypt the backup file
echo "$PASS" | gpg --batch --yes --passphrase-fd 0 -o backup.tar.gz -d *.tar.gz.gpg

# Extract the tar file
tar -xzf backup.tar.gz -C /

rm *.tar.gz.gpg
rm *.tar.gz
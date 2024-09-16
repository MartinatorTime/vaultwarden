#!/bin/bash

sqlite3 /data/db.sqlite3 '.backup /data/db.bak'
tar -czf /backup.tar.gz /data

#Encrypt File and Upload to GitHub
echo "$PASS" | gpg --no-use-agent --batch --yes --passphrase-fd 0 --cipher-algo AES256 --symmetric backup.tar.gz
REPO_NAME="vaultwarden"
TAG="FLY-DATA"
USERNAME="MartinatorTime"

# Check if release already exists
if ! curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$USERNAME/$REPO_NAME/releases/tags/$TAG" | grep -q "tag_name"; then
    
    # Create a new release if it doesn't exist
    RELEASE_ID=$(curl -s -X POST -H "Authorization: token $GITHUB_TOKEN" \
        -d "{\"tag_name\": \"$TAG\"}" \
        "https://api.github.com/repos/$USERNAME/$REPO_NAME/releases" | jq -r '.id')
else
    # Get the existing release ID if it already exists
    RELEASE_ID=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/$USERNAME/$REPO_NAME/releases/tags/$TAG" | jq -r '.id')
fi

# Upload the backup.tar.gz file to the release
curl -X POST -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type: application/octet-stream" \
    --data-binary "@/backup.tar.gz.gpg" \
    "https://uploads.github.com/repos/$USERNAME/$REPO_NAME/releases/$RELEASE_ID/assets?name=backup-$(date +'%d_%m_%Y-%H_%M').tar.gz.gpg"

#rm *.tar.gz.gpg
#rm *.tar.gz
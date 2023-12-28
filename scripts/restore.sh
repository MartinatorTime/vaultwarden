#!/usr/bin/env bash

# Authorize to GitHub to get the latest release tar.gz
# Requires: oauth token, https://help.github.com/articles/creating-an-access-token-for-command-line-use/
# Requires: jq package to parse json

# Your oauth token goes here, see link above
# Repo owner (user id)
OWNER="MartinatorTime"
# Repo name
REPO="vaultwarden"
# The file name expected to download. This is deleted before curl pulls down a new one
FILE_NAME="$1"

# Concatenate the values together for a 
API_URL="https://$GITHUB_TOKEN:@api.github.com/repos/$OWNER/$REPO"

# Gets info on latest release, gets first uploaded asset id of a release,
# More info on jq being used to parse json: https://stedolan.github.io/jq/tutorial/
# Get all the tags for the repository
TAGS=$(curl -s $API_URL/releases | jq -r '.[].tag_name')

# Loop over each tag
for TAG in $TAGS; do
  # Get the asset ID for the file in the current tag
  ASSET_ID=$(curl $API_URL/releases/tags/$TAG | jq -r --arg FILENAME "$FILE_NAME" '.assets[] | select(.name == $FILENAME) | .id')

  # Check if the asset ID is found
  if [[ -n $ASSET_ID ]]; then
    echo "Asset ID: $ASSET_ID"
    break
  fi
done

# curl does not allow overwriting file from -O, nuke
rm *.tar.gz.gpg
rm *.tar.gz
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
#!/bin/bash

# Only run if KEEP_ALIVE is true
if [[ "$KEEP_ALIVE" == "true" ]]; then
  # Ensure URL is provided
  if [ -z "$PING_URL" ]; then
    echo "PING_URL environment variable is required"
    exit 1
  fi

  # Make periodic requests to keep app alive
  while true; do
    curl -s -o /dev/null "$PING_URL"
    sleep 300 # 5 minutes
  done
fi

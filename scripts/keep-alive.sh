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
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Pinging $PING_URL"
    curl -sS -o /dev/null "$PING_URL"
    sleep $((RANDOM % 241 + 180)) # Random between 3-7 minutes
  done
fi

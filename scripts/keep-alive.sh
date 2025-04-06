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
    curl -sS -o /dev/null -H "X-Keep-Alive: true" "$PING_URL"
    sleep $((RANDOM % 241 + 180)) # Random between 3-7 minutes
  done
fi

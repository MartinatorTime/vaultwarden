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
    curl -o /dev/null "$PING_URL" > /dev/null 2>&1
    sleep $((RANDOM % 120 + 60)) # Random between 1-3 minutes
  done
fi

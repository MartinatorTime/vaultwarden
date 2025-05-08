#!/bin/bash

# Only run if KEEP_ALIVE is true
if [[ "$KEEP_ALIVE" == "true" ]]; then
  # Ensure URL is provided
  if [ -z "$PING_URL" ]; then
    echo "PING_URL environment variable is required"
    exit 1
  fi

  # Configuration
  USER_AGENTS=(
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Safari/605.1.15"
  )

  # Make periodic requests to keep app alive
  while true; do
    # Choose a random User-Agent
    USER_AGENT="${USER_AGENTS[$((RANDOM % ${#USER_AGENTS[@]}))]}"

    # Make an asynchronous request
    curl -s -o /dev/null -w "%{http_code}" -H "User-Agent: $USER_AGENT" "$PING_URL"
    REQUEST_STATUS=$?

    if [ $REQUEST_STATUS -eq 0 ]; then
      echo "$(date) - Ping to $PING_URL successful"
    else
      echo "$(date) - Ping to $PING_URL failed with status: $REQUEST_STATUS"
    fi

    # Generate a random sleep interval between 30 seconds and 3 minutes (180 seconds)
    SLEEP_INTERVAL=$((RANDOM % 151 + 30))

    # Sleep for the random interval
    sleep $SLEEP_INTERVAL
  done
fi

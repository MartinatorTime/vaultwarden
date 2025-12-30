#!/bin/bash

# Load Cloudflare credentials from environment
CF_API_TOKEN="${CFAPITOKEN}"
CF_ZONE_ID="${CFZONEID}"

# API endpoint and headers
API_URL="https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/firewall/access_rules/rules"
API_HEADERS=(
  -H 'Content-Type: application/json'
  -H "Authorization: Bearer ${CF_API_TOKEN}"
)

# Get all blocked IP rules
echo "Fetching blocked IP rules..."
response=$(curl -s -X GET "${API_HEADERS[@]}" "${API_URL}?mode=block&page=1&per_page=1000")

# Check if response contains rules
if ! echo "$response" | jq -e '.result' > /dev/null 2>&1; then
  echo "Error fetching rules:"
  echo "$response" | jq
  exit 1
fi

# Extract rule IDs and IPs
rules=$(echo "$response" | jq -r '.result[] | select(.configuration.target == "ip" or .configuration.target == "ip6") | "\(.id) \(.configuration.value)"')

if [ -z "$rules" ]; then
  echo "No blocked IPs found"
  exit 0
fi

# Unban each IP
echo "Unbanning IPs..."
echo "$rules" | while read -r rule_id ip; do
  echo "Unbanning $ip (rule ID: $rule_id)"
  delete_response=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE "${API_HEADERS[@]}" "${API_URL}/${rule_id}")
  
  if [ "$delete_response" -eq 200 ]; then
    echo "Successfully unbanned $ip"
    fail2ban-client unban --all
  else
    echo "Failed to unban $ip (HTTP $delete_response)"
  fi
done

echo "Unban process completed"

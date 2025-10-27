#!/bin/bash
if [[ "$IS_PRIVILEGED" == "true" ]]; then
    sysctl -w net.core.rmem_max=8388608
    sysctl -w net.core.wmem_max=8388608
    cloudflared tunnel --autoupdate-freq "24h" --protocol "quic" --loglevel "error" run --url "http://localhost:80" --token "$CF_TOKEN"
else
    cloudflared tunnel --autoupdate-freq "24h" --protocol "http2" --loglevel "error" run --url "http://localhost:80" --token "$CF_TOKEN"
fi
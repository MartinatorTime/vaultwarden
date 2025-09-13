#!/bin/bash
cloudflared tunnel --autoupdate-freq "24h" --protocol "http2" --loglevel "error" run --url "http://localhost:80" --token "$CF_TOKEN"
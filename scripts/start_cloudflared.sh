#!/bin/bash
cloudflared tunnel --no-autoupdate run --protocol quic --token "$CF_TOKEN" --url "http://localhost:8080"

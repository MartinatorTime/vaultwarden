#!/bin/bash
cloudflared tunnel --no-autoupdate run --protocol http2 --token "$CF_TOKEN" --url "http://localhost:8080"

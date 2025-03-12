#!/bin/bash
cloudflared tunnel --no-autoupdate run --protocol http2 --url "http://localhost:8080" --token "$CF_TOKEN"
#!/bin/bash
cloudflared tunnel --no-autoupdate run --protocol http2 --url "http://localhost:80" --token "$CF_TOKEN"
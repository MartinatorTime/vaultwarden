#!/bin/bash
cloudflared tunnel --no-autoupdate run --protocol auto --token "$CF_TOKEN" --url "http://localhost:8080"
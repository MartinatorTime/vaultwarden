#!/bin/bash
cloudflared tunnel --no-autoupdate run --token "$CF_TOKEN" --url "http://localhost:8080"
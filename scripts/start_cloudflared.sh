#!/bin/bash
cloudflared tunnel --no-autoupdate run --loglevel debug --protocol quic --token "$CF_TOKEN"
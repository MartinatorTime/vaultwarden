#!/bin/bash
cloudflared tunnel --no-autoupdate run --protocol quic --token "$CF_TOKEN" --loglevel "debug"
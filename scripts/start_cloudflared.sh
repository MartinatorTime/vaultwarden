#!/bin/bash
cloudflared tunnel --autoupdate-freq 24h --protocol quic --loglevel error --url "http://localhost:80" --token "$CF_TOKEN"
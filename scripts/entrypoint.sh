#!/bin/bash

# Set sysctl parameters
sysctl -w net.core.rmem_max=8388608
sysctl -w net.core.wmem_max=8388608
sysctl -w net.ipv4.tcp_rmem='4096 87380 16777216'
sysctl -w net.ipv4.tcp_wmem='4096 87380 16777216'
sysctl -w net.ipv4.tcp_mem='16777216 16777216 16777216'
sysctl -w net.ipv4.udp_mem='16777216 16777216 16777216'
sysctl -w net.ipv4.ping_group_range="0 0"

# Set up swap space
SWAPFILE="/.fly-upper-layer/swapfile"

if [ ! -f "$SWAPFILE" ]; then
    echo "Creating swap file..."
    dd if=/dev/zero of=$SWAPFILE bs=1M count=256
    chmod 600 $SWAPFILE
    mkswap $SWAPFILE
    swapon $SWAPFILE
else
    echo "Swap file already exists. Skipping creation."
fi

# Run the original entrypoint
exec "$@"

#!/bin/bash

# Increase the ping_group_range
echo "0 1024" > /proc/sys/net/ipv4/ping_group_range

# Set sysctl parameters
sysctl -w net.core.rmem_max=8388608
sysctl -w net.core.wmem_max=8388608
sysctl -w net.ipv4.tcp_rmem='4096 87380 16777216'
sysctl -w net.ipv4.tcp_wmem='4096 87380 16777216'
sysctl -w net.ipv4.tcp_mem='16777216 16777216 16777216'
sysctl -w net.ipv4.udp_mem='16777216 16777216 16777216'

# Execute the CMD
exec "$@"
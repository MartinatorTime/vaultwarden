#!/bin/sh
sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove && sudo apt clean -y
rm -rf /etc/ssl/certs
sudo apt install --reinstall ca-certificates

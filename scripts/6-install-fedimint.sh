#!/bin/sh

# Check if the script is running with superuser (root) privileges
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

##############################
# INSTALL FEDIMINT
##############################
echo "::: Installing Fedimint"
echo

# Install Fedimint into /opt folder.
cd /opt
curl -sSL https://raw.githubusercontent.com/fedimint/fedimint/master/docker/download-mutinynet.sh | bash
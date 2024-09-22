#!/bin/sh

# Check if the script is running with superuser (root) privileges
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

##############################
# INSTALL UTILITY TOOLS
##############################
echo "::: Installing utility tools (curl, nano)"
echo
apk add curl nano

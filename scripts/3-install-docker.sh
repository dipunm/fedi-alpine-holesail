#!/bin/sh

# Check if the script is running with superuser (root) privileges
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

##############################
# INSTALL DOCKER
##############################
echo "::: Installing Docker"
apk add docker docker-compose
addgroup docker docker
rc-update add docker default
service docker start

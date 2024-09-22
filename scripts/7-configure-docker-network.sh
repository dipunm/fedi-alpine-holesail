#!/bin/sh

# Check if the script is running with superuser (root) privileges
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

##############################
# CONFIGURE DOCKER NETWORK
##############################
echo "::: Configuring a common docker network"
echo

docker network create caddy_net
docker network connect caddy_net caddy
docker network connect caddy_net fedimintd
docker network connect caddy_net guardian-ui
docker network connect caddy_net gateway-ui

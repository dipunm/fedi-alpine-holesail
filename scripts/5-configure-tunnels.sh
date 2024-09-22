#!/bin/sh

# Check if the script is running with superuser (root) privileges
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

##############################
# CONFIGURE TUNNELS
##############################
echo "::: Configuring holesail"
echo
echo "################################
INSTRUCTIONS:

We are about to configure a startup script file.
This file has three calls to the holesail application for the following purposes:

1. HTTP traffic sent to Caddy on port 80
2. HTTPS traffic sent to Caddy on port 443
3. TCP traffic sent directly to Fedimint on port 8173

Each line requires a unique connector (aka connection string).
This should be at least 32 characters long, and must NOT be exactly 64 characters long.

Caddy can redirect requests based on the hostname of HTTP and HTTPS requests.
This startup script combined with a custom Caddyfile configuration should be enough 
to access all of our fedimint endpoints:

- Port 3000: Fedimintd Guardian Dashboard (http)
- Port 3001: Lightning Gateway Dashboard (http)
- Port 3003: RTL Lightning Node Management (http)
- Port 8174: Gateway API (http)
- Port 8173: Fedimintd p2p (tcp)
################################

" | more
echo "Entering edit mode for: /etc/local.d/holesail.start."
read -n 1 -s -p "Press any key to continue."

nano /etc/local.d/holesail.start

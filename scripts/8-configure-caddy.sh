#!/bin/sh

# Check if the script is running with superuser (root) privileges
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

##############################
# CONFIGURE CADDY
##############################
echo "
{
	email me@example.com

	acme_dns porkbun {
		api_key pk1_
		api_secret_key sk1_
	}
}

portainer.satsnode.xyz {
	reverse_proxy http://fedimint:9000
}
" > /etc/caddy/Caddyfile
nano /etc/caddy/Caddyfile

caddy reload
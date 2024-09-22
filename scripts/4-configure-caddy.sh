#!/bin/sh

# Check if the script is running with superuser (root) privileges
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

##############################
# CONFIGURE AND RUN CADDY
##############################
mkdir -p /etc/caddy
touch /etc/caddy/Caddyfile

docker volume create caddy_data
docker volume create caddy_config

mkdir -p /etc/caddy/build
echo "FROM caddy:2-builder as builder

# Find and include the correct module for your DNS provider:
# https://caddyserver.com/docs/modules/
# (Search: dns.providers)

RUN xcaddy build \
    --with github.com/caddy-dns/porkbun

FROM caddy:2

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
" > /etc/caddy/build/Dockerfile

echo "################################
INSTRUCTIONS:

We are about to configure a Dockerfile so that it can run Caddy with
auto TLS enabled.

This will allow us to route to our internal http endpoints over SSL
with a valid SSL certificate!

You should visit https://caddyserver.com/docs/modules/ and search for
the appropriate module for your DNS provider.

Caddy will automatically create let's encrypt SSL certificates for
your endpoints, however you will need to configure access keys to
allow this based on instructions unique to your chosen module and DNS
provider.

After editing and saving the document, the script will continue to
build and run it for you.
################################

" | more
echo "Entering edit mode for: /etc/caddy/build/Dockerfile."
read -n 1 -s -p "Press any key to continue."

nano /etc/caddy/build/Dockerfile

docker build -t caddy-local:latest /etc/caddy/build

# create a caddy proxy executable
echo docker exec -w /etc/caddy \$\(docker ps -aqf "name=^caddy\$"\) caddy \$@ \
    > /usr/local/bin/caddy
chmod +x /usr/local/bin/caddy

# create a caddy reinstallation script
echo "docker build -t caddy-local:latest /etc/caddy/build \\
    && docker stop caddy \\
    && docker rm caddy \\
    && docker run -d \\
    -p 443:443 -p 443:443/udp \\
    --name=caddy --restart=unless-stopped \\
    -v /etc/caddy/Caddyfile:/etc/caddy/Caddyfile \\
    -v caddy_data:/data \\
    -v caddy_config:/config \\
    -v /srv:/srv \\
    caddy-local:latest" > /usr/local/bin/reinstall-caddy
chmod +x /usr/local/bin/reinstall-caddy

docker run -d \
    -p 443:443 -p 443:443/udp \
    --name=caddy --restart=unless-stopped \
    -v /etc/caddy/Caddyfile:/etc/caddy/Caddyfile \
    -v caddy_data:/data \
    -v caddy_config:/config \
    -v /srv:/srv \
    caddy-local:latest

echo "
################################
INFORMATION: 

Caddy can be configured by editing the following file:

    /etc/caddy/Caddyfile

After making changes, you will need to restart caddy. This can be done by executing the following command:

\`\`\`sh
    caddy reload
\`\`\`

The base Dockerfile for your Caddy installation can be found here:

    /etc/caddy/build/Dockerfile

If you need to make changes to this file, you will need to run the following command to update the Caddy installation:

\`\`\`sh
    reinstall-caddy
\`\`\`
################################
" | more
read -n 1 -s -p "Press any key to continue."
echo
echo
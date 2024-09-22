#!/bin/sh

# Check if the script is running with superuser (root) privileges
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

##############################
# INSTALL HOLESAIL
#
# We must build from source in order for it to work on Alpine Linux
# I was also unable to get it to work inside a docker container in my tests.
#
# Source: 
# - https://github.com/holesail/holesail/issues/2#issuecomment-2275100855
# - https://github.com/holesail/holesail/issues/16#issuecomment-2351073644
##############################
echo "::: Installing Holesail"
echo
apk add git
cd /opt
git clone https://github.com/holesail/holesail.git
cd holesail
apk add nodejs npm
apk add python3
apk add autoconf
apk add automake
apk add make
apk add build-base

npm i --build-from-source --foreground-scripts

# Make executable accessible from PATH
echo "node /opt/holesail/index.js \$@" > /usr/local/bin/holesail
chmod +x /usr/local/bin/holesail
touch /etc/local.d/holesail.start
echo "# holesail startup script

#####################################
# This script MUST exit without any interactivity.
# Non-terminating scripts will prevent you from booting to an interactive terminal and brick your OS installation.
# 
# The holesail command is a long running application that does not exit by default.
# We MUST promote it to the background by appending an ampersand (&) to the end of the command:
# 
# \`\`\`sh
# holesail --live 443 --connector 'xyz' &
# \`\`\`
#####################################

# Uncomment the appropriate lines and provide a unique connector for each one:

# holesail --live 443 --connector \"insert-a-unique-uri-or-string-here-32-chars-minimum-https\" &
# holesail --live 80 --connector \"insert-a-unique-uri-or-string-here-32-chars-minimum-http\" &
# holesail --live 8173 --connector \"insert-a-unique-uri-or-string-here-32-chars-minimum-tcp\" &
" > /etc/local.d/holesail.start

chmod +x /etc/local.d/holesail.start
rc-update add local default
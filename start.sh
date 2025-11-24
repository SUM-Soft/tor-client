#!/bin/sh
set -e

# Use provided USERNAME and PASSWORD or default them.
# A warning is printed if the defaults are used.
if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
    echo "WARNING: USERNAME or PASSWORD not set. Using default credentials 'user:password'."
    USERNAME=${USERNAME:-user}
    PASSWORD=${PASSWORD:-password}
fi

echo "Configuring gost v3 proxy..."
GOST_CONF_DIR=/etc/gost
mkdir -p $GOST_CONF_DIR

# Dynamically create the gost config file for v3
cat <<EOF > $GOST_CONF_DIR/gost.yml
chains:
  - name: tor-chain
    hops:
      - name: tor-hop
        nodes:
          - name: tor-node
            addr: 127.0.0.1:9050
            connector:
              type: socks5
services:
  - name: socks5-proxy
    addr: ":1080"
    handler:
      type: socks5
      auths:
        - username: "${USERNAME}"
          password: "${PASSWORD}"
    listener:
      type: tcp
    chain: tor-chain
log:
  format: text
  level: warn
EOF
echo "gost configured."

echo "Starting gost SOCKS5 proxy in the background..."
su-exec gost gost -C $GOST_CONF_DIR/gost.yml &
echo "gost proxy started."

echo "Starting Tor. It may take a minute to bootstrap and connect to the network."
echo "You can monitor the logs below. Look for 'Bootstrapped 100%' before connecting your client."
# Start tor in the foreground as the tor user
exec su-exec tor /usr/bin/tor -f /etc/torrc
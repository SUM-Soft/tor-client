#!/bin/sh
set -e

# Use provided USERNAME and PASSWORD or default them.
# A warning is printed if the defaults are used.
if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
    echo "WARNING: USERNAME or PASSWORD not set. Using default credentials 'user:password'."
    USERNAME=${USERNAME:-user}
    PASSWORD=${PASSWORD:-password}
fi

echo "Configuring 3proxy..."
PROXY_CONF_DIR=/etc/3proxy
mkdir -p $PROXY_CONF_DIR

# Dynamically create the 3proxy config file
cat <<EOF > $PROXY_CONF_DIR/3proxy.cfg
fakeresolve
timeouts 10 30 60 60 180 1800 30 60
auth strong
users ${USERNAME}:CL:${PASSWORD}
allow ${USERNAME}
parent 1000 socks5+ 127.0.0.1 9050
socks -p1080
EOF
echo "3proxy configured."

echo "Starting 3proxy in the background..."
3proxy $PROXY_CONF_DIR/3proxy.cfg &
echo "3proxy started."

echo "Starting Tor. It may take a minute to bootstrap and connect to the network."
echo "You can monitor the logs below. Look for 'Bootstrapped 100%' before connecting your client."
# Start tor in the foreground as the tor user
exec su-exec tor /usr/bin/tor -f /etc/torrc
FROM alpine:3.20.0

HEALTHCHECK --interval=60s --timeout=30s --start-period=30s \
  CMD curl --fail --socks5 localhost:32905 --socks5-hostname localhost:32905 https://check.torproject.org/api/ip | grep '"IsTor":true' || exit 1

# hadolint ignore=DL3018
RUN apk --update --no-cache add tor curl \
    && rm -rf /var/cache/apk/*

COPY torrc /etc/torrc

USER "tor"

WORKDIR "/var/lib/tor"

EXPOSE 32905

ENTRYPOINT ["/usr/bin/tor", "-f", "/etc/torrc"]

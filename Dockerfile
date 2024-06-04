FROM alpine:latest

#HEALTHCHECK --interval=60s --timeout=30s --start-period=30s \
#  CMD curl --fail --socks5 localhost:9050 --socks5-hostname localhost:9050 https://check.torproject.org/api/ip || exit 1

# hadolint ignore=DL3018
RUN apk --update --no-cache add tor \
    && rm -rf /var/cache/apk/*

COPY torrc /etc/torrc

USER "tor"

WORKDIR "/var/lib/tor"

EXPOSE 9050

ENTRYPOINT ["/usr/bin/tor", "-f", "/etc/torrc"]

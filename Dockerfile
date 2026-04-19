FROM alpine:3.23.4

HEALTHCHECK --interval=60s --timeout=30s --start-period=30s \
  CMD curl --fail --socks5-hostname localhost:1080 --proxy-user "${USERNAME:-user}:${PASSWORD:-password}" https://check.torproject.org/api/ip | grep '\"IsTor\":true' || exit 1

# Install runtime dependencies
# hadolint ignore=DL3018
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
  && apk --update --no-cache add tor curl 3proxy \
  && rm -rf /var/cache/apk/*

COPY start.sh /start.sh

RUN sed -i 's/\r$//' /start.sh && chmod +x /start.sh

RUN mkdir -p /etc/3proxy && chown -R tor:tor /etc/3proxy /var/lib/tor

WORKDIR "/var/lib/tor"

USER tor

EXPOSE 1080

ENTRYPOINT ["/start.sh"]
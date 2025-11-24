FROM alpine:3.22.2

ENV GOST_VERSION=3.2.6

HEALTHCHECK --interval=60s --timeout=30s --start-period=30s \
  CMD curl --fail --socks5-hostname localhost:1080 --proxy-user "${USERNAME:-user}:${PASSWORD:-password}" https://check.torproject.org/api/ip | grep '\"IsTor\":true' || exit 1

# hadolint ignore=DL3018
RUN apk --update --no-cache add tor curl su-exec \
    && adduser -S -s /bin/false gost \
    && apk add --virtual .build-deps wget tar \
    && GOST_ARCH=$(uname -m) \
    && if [ "$GOST_ARCH" = "x86_64" ]; then GOST_ARCH=amd64; fi \
    && if [ "$GOST_ARCH" = "aarch64" ]; then GOST_ARCH=arm64; fi \
    && wget "https://github.com/go-gost/gost/releases/download/v${GOST_VERSION}/gost_${GOST_VERSION}_linux_${GOST_ARCH}.tar.gz" \
    && tar -xvf "gost_${GOST_VERSION}_linux_${GOST_ARCH}.tar.gz" \
    && mv gost /usr/local/bin/gost \
    && chmod +x /usr/local/bin/gost \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/* "gost_${GOST_VERSION}_linux_${GOST_ARCH}.tar.gz"

COPY torrc /etc/torrc
COPY start.sh /start.sh

RUN chmod +x /start.sh

WORKDIR "/var/lib/tor"

EXPOSE 1080

ENTRYPOINT ["/start.sh"]
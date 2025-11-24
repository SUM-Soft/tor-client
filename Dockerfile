# Stage 1: Build 3proxy
FROM alpine:3.22.2 AS builder

ARG THREEPROXY_VERSION=0.9.5

WORKDIR /usr/src/3proxy

RUN apk add --no-cache build-base linux-headers wget tar \
  && wget -O 3proxy.tar.gz "https://github.com/3proxy/3proxy/archive/refs/tags/${THREEPROXY_VERSION}.tar.gz" \
  && tar -xzf 3proxy.tar.gz --strip-components=1 \
  && make -f Makefile.Linux \
  && BINARY_PATH=$(find . -type f -name 3proxy | head -n 1) \
  && if [ -z "$BINARY_PATH" ]; then echo "Binary not found!"; ls -R; exit 1; fi \
  && cp "$BINARY_PATH" /usr/src/3proxy/3proxy \
  && strip /usr/src/3proxy/3proxy

# Stage 2: Final Image
FROM alpine:3.22.2

HEALTHCHECK --interval=60s --timeout=30s --start-period=30s \
  CMD curl --fail --socks5-hostname localhost:1080 --proxy-user "${USERNAME:-user}:${PASSWORD:-password}" https://check.torproject.org/api/ip | grep '\"IsTor\":true' || exit 1

# Install runtime dependencies (no 3proxy package needed)
# hadolint ignore=DL3018
RUN apk --update --no-cache add tor curl su-exec \
  && rm -rf /var/cache/apk/*

# Copy compiled binary from builder (Fixed path)
COPY --from=builder /usr/src/3proxy/3proxy /usr/local/bin/3proxy

COPY torrc /etc/torrc
COPY start.sh /start.sh

RUN sed -i 's/\r$//' /start.sh && chmod +x /start.sh

WORKDIR "/var/lib/tor"

EXPOSE 1080

ENTRYPOINT ["/start.sh"]
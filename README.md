# Tor Client with Authenticated SOCKS5 Proxy
[![Pipeline](https://github.com/SUM-Soft/tor-client/actions/workflows/pipeline.yml/badge.svg)](https://github.com/SUM-Soft/OrpheusVPN/actions/workflows/pipeline.yml)

This project provides a Docker container running a Tor client with an authenticated SOCKS5 proxy powered by `3proxy`.

## Build the image

```bash
docker build -t tor-client .
```

## Run the container

You can run the container and set your desired username and password for the proxy.

**Security Notice:** For security reasons, you should always set your own `USERNAME` and `PASSWORD` when running the container. The container will use default credentials (`user:password`) if these are not provided, which is insecure for any real use case.

```bash
docker run --rm -p 1080:1080 \
  -e USERNAME=myuser \
  -e PASSWORD=mypassword \
  tor-client
```

If you don't provide `USERNAME` and `PASSWORD` environment variables, the container will fall back to default credentials and print a warning.

When the container starts, wait for the Tor process to bootstrap. You will see log messages, and you should wait for `Bootstrapped 100% (done): Done` before attempting to use the proxy.

## Custom torrc Configuration

You can provide your own `torrc` configuration file mounting to `/etc/tor/torrc`:

    ```bash
    docker run --rm -p 1080:1080 \
      -v $(pwd)/my-custom-torrc:/etc/tor/torrc \
      tor-client
    ```

If neither is provided, the container generates a default configuration with reasonable defaults (SocksPort 9050, logging to stdout, etc.).

## How to use

Configure your application to use a **SOCKS5 proxy** at `127.0.0.1:1080` with the username and password you set.

### Example with curl

You can test the proxy with `curl`:

```bash
curl --socks5 127.0.0.1:1080 --proxy-user "myuser:mypassword" https://check.torproject.org/api/ip
```

The output should show that you are connected through Tor:
```json
{"IsTor":true,"IP":"...","Country":"..."}
```
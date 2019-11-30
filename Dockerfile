FROM debian:latest

# Cloudflared
WORKDIR /app/cloudflare/

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y wget \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN wget -O- https://bin.equinox.io/c/VdrWdbjqyF/cloudflared-stable-linux-amd64.tgz | tar xz

RUN echo "\
proxy-dns: true \n\
proxy-dns-address: 0.0.0.0 \n\
proxy-dns-upstream: \n\
  # - https://1.1.1.1/dns-query  \n\
  - https://1.0.0.1/dns-query    \n\
  - https://dns.google/dns-query \n\
" > config.yml

EXPOSE 53
EXPOSE 53/udp

ENTRYPOINT ["./cloudflared", "--config", "config.yml"]

FROM golang:alpine as builder

ARG TARGETARCH
WORKDIR /app

RUN apk --no-cache --no-progress add \
    wget
 
#RUN wget -O- https://bin.equinox.io/c/VdrWdbjqyF/cloudflared-stable-linux-amd64.tgz | tar xz
RUN wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${TARGETARCH} -O cloudflared


# FROM alpine
# RUN apk --no-cache --no-progress add \
#     ca-certificates 

FROM debian:stable-slim
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y ca-certificates \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/cloudflared /usr/local/bin
RUN chmod +x /usr/local/bin/cloudflared

WORKDIR /app
RUN echo "\
proxy-dns: true \n\
proxy-dns-address: 0.0.0.0 \n\
proxy-dns-upstream: \n\
  - https://1.0.0.1/dns-query \n\
  - https://1.1.1.1/dns-query \n\
  - https://dns.adguard.com/dns-query \n\
" > config.yml

EXPOSE 53
EXPOSE 53/udp

#USER nonroot

ENTRYPOINT ["cloudflared", "--config", "/app/config.yml"]

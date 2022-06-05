FROM golang:debian as builder

# Cloudflared
ARG architecture
WORKDIR /app

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y wget \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
 
RUN case $(uname -m) in \
        i386)   architecture="386" ;; \
        i686)   architecture="386" ;; \
        x86_64) architecture="amd64" ;; \
        arm)    dpkg --print-architecture | grep -q "arm64" && architecture="arm64" || architecture="arm" ;; \
    esac

#RUN wget -O- https://bin.equinox.io/c/VdrWdbjqyF/cloudflared-stable-linux-amd64.tgz | tar xz
RUN echo ${architecture}
RUN url=https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${architecture} \
 && echo $url \
 && wget $url -O cloudflared

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
  - https://1.0.0.1/dns-query  \n\
  - https://1.1.1.1/dns-query  \n\
" > config.yml

EXPOSE 53
EXPOSE 53/udp

ENTRYPOINT ["cloudflared", "--config", "/app/config.yml"]

FROM golang:alpine as builder

ARG TARGETARCH
WORKDIR /app

RUN apk --no-cache --no-progress add \
    wget
 
#RUN wget -O- https://bin.equinox.io/c/VdrWdbjqyF/cloudflared-stable-linux-amd64.tgz | tar xz
RUN echo ${architecture}
RUN url=https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${TARGETARCH} \
 && echo $url \
 && wget $url -O cloudflared

FROM alpine
RUN apk --no-cache --no-progress add \
    ca-certificates 
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

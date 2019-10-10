# DoH

## docker-compose
```
version: '3'
services:
  cloudflared:
    image: mnxzyw/cloudflared:latest
    container_name: cloudflared
    restart: unless-stopped
    ports:
      - 53:53/udp
    logging:
      driver: "json-file"
      options:
        max-size: "1g"
        max-file: "3"
        compress: "true"
```

## Run
- docker-compose up -d  

## View connection
- [Connection Information](https://1.1.1.1/help)

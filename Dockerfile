FROM golang:1.22 as builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build ./...

RUN go install ./...

FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    curl

COPY --from=builder /go/bin/tesla-* /usr/local/bin/

RUN groupadd -g 72277 sbapp
RUN useradd -ms /bin/bash -g sbapp -u 1001 scooterbot
USER scooterbot

CMD [ \
  "tesla-http-proxy", \
  "-key-file", "/sb/config/tesla/com.tesla.3p.private-key.pem", \
  "-cert", "/sb/config/tesla_vcmd_proxy/proxy_cert.pem", \
  "-tls-key", "/sb/config/tesla_vcmd_proxy/proxy_key.pem", \
  "-host", "0.0.0.0", \
  "-port", "443", \
  "-verbose" \
]

FROM golang:1.23.0 AS build

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN mkdir build
RUN go build -o ./build ./...

FROM gcr.io/distroless/base-debian12:nonroot AS runtime

COPY --from=build /app/build /usr/local/bin

USER 1001:72277

CMD [ \
  "tesla-http-proxy", \
  "-key-file", "/sb/config/tesla/com.tesla.3p.private-key.pem", \
  "-cert", "/sb/config/tesla_vcmd_proxy/proxy_cert.pem", \
  "-tls-key", "/sb/config/tesla_vcmd_proxy/proxy_key.pem", \
  "-host", "0.0.0.0", \
  "-port", "443", \
  "-verbose" \
]

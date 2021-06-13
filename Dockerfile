FROM alpine AS builder
WORKDIR /app

RUN apk add --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community --no-cache git go
RUN git clone https://github.com/klzgrad/forwardproxy -b naive --depth 1 && \
    go get -u github.com/caddyserver/xcaddy/cmd/xcaddy && \
    # Use cloned repo for now
    # https://github.com/klzgrad/naiveproxy/issues/164
    ~/go/bin/xcaddy build --with github.com/caddyserver/forwardproxy@caddy2=$PWD/forwardproxy \
        --with github.com/lucas-clemente/quic-go@master

###

FROM alpine

COPY --from=builder /app/caddy /usr/bin/caddy

ARG PATH
VOLUME /etc/naiveproxy
CMD /usr/bin/caddy run --config ${PATH}

FROM alpine:3.7

ENV NGINX_VERSION 1.12.2

RUN apk update
RUN apk --no-cache add nginx=1.12.2-r3 supervisor curl nodejs=8.9.4-r0 nodejs-npm=8.9.4-r0 \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/main/

# Clean Image
RUN rm -rf /tmp/* \
    && rm -rf /var/tmp/* \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/cache/apk/*


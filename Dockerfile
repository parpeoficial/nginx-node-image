FROM alpine:3.7

ENV NODE_VERSION=8.9.4
ENV LANG=C.UTF-8

# Install NGINX
RUN apk update
RUN apk --no-cache add nginx=1.14.0-r0 supervisor curl --repository http://dl-cdn.alpinelinux.org/alpine/edge/main/
ADD config/nginx /etc/nginx

# Install NODEJS
RUN apk add --no-cache libstdc++
RUN apk add --no-cache --virtual .build-deps binutils-gold g++ gcc gnupg libgcc linux-headers make python
RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.xz" && \
    tar -xf "node-v$NODE_VERSION.tar.xz" && \
    cd "node-v$NODE_VERSION" && \
    ./configure && \
    make -j$(getconf _NPROCESSORS_ONLN) && \
    make install && \
    apk del .build-deps && \
    cd .. && \
    rm -Rf "node-v$NODE_VERSION"

# Install GLIBC
RUN ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \
    ALPINE_GLIBC_PACKAGE_VERSION="2.27-r0" && \
    ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    wget \
    "https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub" \
    -O "/etc/apk/keys/sgerrand.rsa.pub" && \
    wget \
    "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
    "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
    "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    apk add --no-cache \
    "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
    "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
    "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    \
    rm "/etc/apk/keys/sgerrand.rsa.pub" && \
    /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true && \
    echo "export LANG=$LANG" > /etc/profile.d/locale.sh && \
    \
    apk del glibc-i18n && \
    \
    rm "/root/.wget-hsts" && \
    apk del .build-dependencies && \
    rm \
    "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
    "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
    "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"

RUN node -v
RUN npm -v

EXPOSE 80 443
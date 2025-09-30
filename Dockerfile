FROM node:lts-alpine3.22

LABEL org.opencontainers.image.url="https://github.com/misotolar/docker-node-media-server"
LABEL org.opencontainers.image.description="Node Media Server Alpine Linux image"
LABEL org.opencontainers.image.authors="Michal Sotolar <michal@sotolar.com>"

ENV NMS_VERSION=2.7.4
ARG SHA256=59888d705e52255f9292a4373e934912c63b4284e5689c325d4188f035517610
ADD https://github.com/illuspas/Node-Media-Server/archive/refs/tags/v$NMS_VERSION.tar.gz /tmp/node-media-server.tar.gz

ENV APP_RTMP_PORT=1935
ENV APP_RTMP_HOST=0.0.0.0
ENV APP_RTMP_CHUNK_SIZE=60000
ENV APP_RTMP_GOP_CACHE=true
ENV APP_RTMP_PING=30
ENV APP_RTMP_PING_TIMEOUT=60

ENV APP_HTTP_PORT=8000
ENV APP_HTTP_HOST=0.0.0.0
ENV APP_HTTP_ALLOW_ORIGIN=*
ENV APP_HTTP_API=true

ENV APP_AUTH_API=true
ENV APP_AUTH_API_USER=admin
ENV APP_AUTH_API_PASS=admin
ENV APP_AUTH_PLAY=false
ENV APP_AUTH_PUBLISH=false
ENV APP_AUTH_SECRET=nodemediasecret

COPY resources/patches/0001-node-http-server-host.patch /tmp/patches/
COPY resources/patches/0002-node-rtmp-server-host.patch /tmp/patches/

WORKDIR /usr/local/node-media-server

RUN set -ex; \
    apk add --no-cache \
        gettext-envsubst \
    ; \
    apk add --no-cache --virtual .build-deps \
        patch \
    ; \
    echo "$SHA256 */tmp/node-media-server.tar.gz" | sha256sum -c -; \
    tar xf /tmp/node-media-server.tar.gz --strip-components=1; \
    patch -p1 < /tmp/patches/0001-node-http-server-host.patch; \
    patch -p1 < /tmp/patches/0002-node-rtmp-server-host.patch; \
    apk del --no-network .build-deps; \
    npm i; \
    rm -rf \
        /var/cache/apk/* \
        /var/tmp/* \
        /tmp/*

COPY resources/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY resources/app.docker.js .

EXPOSE 1935 8000

STOPSIGNAL SIGKILL
ENTRYPOINT ["entrypoint.sh"]
CMD ["node", "/usr/local/node-media-server/app.js"]

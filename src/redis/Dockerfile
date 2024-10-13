# syntax=docker/dockerfile:1

ARG VERSION_REDIS
FROM redis:${VERSION_REDIS}

LABEL maintainer="István Lantos <lantosistvan89@gmail.com>"

# COPY ./redis.conf.template /tmp/

# RUN set -e \
# 	&& apk add --no-cache --virtual .build-deps \
# 		gettext-envsubst \
# 	&& mkdir -p /run/redis /usr/local/etc/redis \
# 	&& envsubst < /tmp/redis.conf.template > /usr/local/etc/redis/redis.conf \
# 	&& chown -R ${USER_NAME}:${USER_NAME} /data /run/redis \
# 	&& apk del --no-network .build-deps \
# 	&& rm -r /tmp/*.template

# CMD [ "redis-server", "/usr/local/etc/redis/redis.conf" ]

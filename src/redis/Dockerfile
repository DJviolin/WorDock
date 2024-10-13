# syntax=docker/dockerfile:1

ARG VERSION_REDIS
FROM redis:${VERSION_REDIS}

LABEL maintainer="István Lantos <lantosistvan89@gmail.com>"

ARG USER_ID="70"
ARG USER_NAME="postgres"
# ARG USER_NAME="redis"

COPY ./redis.conf.template /tmp/

RUN set -e \
	&& addgroup -g ${USER_ID} -S ${USER_NAME} \
    && adduser -S -D -H -u ${USER_ID} -h /var/cache/${USER_NAME} -s /sbin/nologin -G ${USER_NAME} -g ${USER_NAME} ${USER_NAME} \
	&& apk add --no-cache --virtual .build-deps \
		gettext-envsubst \
	&& mkdir -p /run/redis /usr/local/etc/redis \
	&& envsubst < /tmp/redis.conf.template > /usr/local/etc/redis/redis.conf \
	&& chown -R ${USER_NAME}:${USER_NAME} /data /run/redis \
	&& apk del --no-network .build-deps \
	&& rm -r /tmp/*.template

USER ${USER_NAME}

CMD [ "redis-server", "/usr/local/etc/redis/redis.conf" ]

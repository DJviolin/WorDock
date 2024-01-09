# syntax=docker/dockerfile:1

# https://github.com/docker-library/httpd/blob/master/2.4/alpine/Dockerfile
# https://github.com/laradock/laradock/blob/master/apache2/Dockerfile
# https://httpd.apache.org/docs/2.4/mod/core.html#include

# https://github.com/docker-library/httpd/issues/135
# https://salsa.debian.org/apache-team/apache2/-/blob/master/debian/a2enmod?ref_type=heads

ARG VERSION_APACHE
FROM httpd:${VERSION_APACHE}

LABEL maintainer="István Lantos <lantosistvan89@gmail.com>"

ARG PROJECT_CONTAINER_DIR
ARG USER_NAME
ARG SERVER_NAME
ARG SOCKET

COPY ./zz-docker.conf.template /tmp/

RUN set -e \
	&& apk add --no-cache --virtual .build-deps \
		gettext-envsubst \
	&& apk add --no-cache \
		openssl \
	&& echo -e "\nInclude conf/extra/zz-docker.conf\n" >> $HTTPD_PREFIX/conf/httpd.conf \
	&& envsubst < /tmp/zz-docker.conf.template > $HTTPD_PREFIX/conf/extra/zz-docker.conf \
	&& mkdir -p ${PROJECT_CONTAINER_DIR} \
	&& chown ${USER_NAME}:${USER_NAME} ${PROJECT_CONTAINER_DIR} \
	&& apk del --no-network .build-deps \
	&& rm /tmp/zz-docker.conf.template

EXPOSE 80 443

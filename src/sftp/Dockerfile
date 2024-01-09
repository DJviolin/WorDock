# syntax=docker/dockerfile:1

# https://github.com/atmoz/sftp/blob/master/Dockerfile-alpine
# $ apk list -i

FROM alpine:latest

LABEL maintainer="István Lantos <lantosistvan89@gmail.com>"

ARG PROJECT_CONTAINER_DIR
ARG SFTP_PASSWORD
ARG USER_ID
ARG USER_NAME

COPY ./sshd_config.template /tmp/

RUN set -e \
	# Next line is uncommented, because `www-data` group already present in Alpine
	# && addgroup -g ${USER_ID} -S ${APP_USER} \
    && adduser -S -D -H -u ${USER_ID} -h /var/cache/${USER_NAME} -s /sbin/nologin -G ${USER_NAME} -g ${USER_NAME} ${USER_NAME} \
	&& echo "${USER_NAME}:${SFTP_PASSWORD}" | chpasswd \
	&& apk add --no-cache --virtual .build-deps \
		gettext-envsubst \
	&& apk add --no-cache \
		openssh \
	&& envsubst < /tmp/sshd_config.template > /etc/ssh/sshd_config \
	&& ssh-keygen -A \
	&& mkdir -p ${PROJECT_CONTAINER_DIR} \
	&& chown ${USER_NAME}:${USER_NAME} ${PROJECT_CONTAINER_DIR} \
	&& apk del --no-network .build-deps \
	&& rm /tmp/sshd_config.template

WORKDIR ${PROJECT_CONTAINER_DIR}

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D", "-e"]

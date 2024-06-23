# syntax=docker/dockerfile:1

ARG VERSION_CERTS
FROM alpine:${VERSION_CERTS}

LABEL maintainer="István Lantos <lantosistvan89@gmail.com>"

ARG SERVER_NAME
ENV SERVER_NAME="${SERVER_NAME}"

COPY ./entrypoint.sh ./init.sh /

RUN set -e \
	&& apk add --no-cache \
		openssl \
		supercronic \
	&& apk add --no-cache \
		--repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
		--repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
		--repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
			mkcert \
	&& mkdir -p /etc/letsencrypt/live/${SERVER_NAME} \
	# https://crontab.cronhub.io/
	# At 12:00 AM, every 30 days: 0 0 */30 * *
	# At 12:00 AM and 12:00 PM: 0 0,12 * * *
	&& echo "0 0 */30 * * /init.sh" > /opt/crontabs/root

CMD ["/entrypoint.sh"]

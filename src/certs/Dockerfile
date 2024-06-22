# syntax=docker/dockerfile:1

# https://certbot.eff.org/instructions?ws=webproduct&os=pip&tab=wildcard
# https://certbot-dns-cloudflare.readthedocs.io/en/stable/
# https://certbot.eff.org/instructions?ws=apache&os=pip
# https://crontab.cronhub.io/

# https://mindsers.blog/en/post/https-using-nginx-certbot-docker/
# https://hub.docker.com/r/certbot/certbot
# https://eff-certbot.readthedocs.io/en/latest/install.html#alternative-1-docker
# https://hub.docker.com/r/nginxproxy/acme-companion

# https://mindsers.blog/en/post/https-using-nginx-certbot-docker/
# $ docker run -it --rm -v "./secrets/:/secrets/" alpine/openssl:latest req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /secrets/docker.test.key -out /secrets/docker.test.crt -subj "/C=HU/ST=Pest/L=Budapest/O=Docker Compose Company/CN=docker.test"
# $ docker run -it --rm ymuski/curl-http3 curl -V
# $ cd C:\APPS\curl-8.6.0_1-win64-mingw\bin
# $ curl -ILk https://docker.test/benchmark_json --http3

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
			certbot \
			certbot-dns-cloudflare \
			mkcert \
	&& mkdir -p /opt/crontabs /var/www/certbot /etc/letsencrypt /var/lib/letsencrypt /var/log/letsencrypt \
	&& mkdir -p /etc/letsencrypt/archive/${SERVER_NAME} /etc/letsencrypt/live/${SERVER_NAME} \
	# At 12:00 AM, every 30 days: 0 0 */30 * *
	# At 12:00 AM and 12:00 PM: 0 0,12 * * *
	&& echo "0 0 */30 * * /init.sh" > /opt/crontabs/root

CMD ["/entrypoint.sh"]

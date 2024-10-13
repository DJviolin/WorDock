# syntax=docker/dockerfile:1

# https://github.com/docker-library/wordpress/blob/master/latest/php8.3/fpm-alpine/Dockerfile

ARG VERSION_PHP
FROM php:${VERSION_PHP}

LABEL maintainer="István Lantos <lantosistvan89@gmail.com>"

ARG VERSION_PHP

RUN set -e \
	# Use the default production configuration
	&& mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
	# Persistent dependencies
	&& apk add --no-cache \
		ghostscript \
		imagemagick \
	# https://make.wordpress.org/hosting/handbook/handbook/server-environment/#php-extensions
	&& apk add --no-cache --virtual .build-deps \
		$PHPIZE_DEPS \
		freetype-dev \
		icu-dev \
		imagemagick-dev \
		libjpeg-turbo-dev \
		libpng-dev \
		libwebp-dev \
		libzip-dev \
	&& docker-php-ext-configure gd \
		--with-freetype \
		--with-jpeg \
		--with-webp \
	&& docker-php-ext-install -j "$(nproc)" \
		bcmath \
		exif \
		gd \
		intl \
		mysqli \
		zip \
	# https://pecl.php.net/package/imagick
	# https://github.com/Imagick/imagick/issues/328
	&& pecl install \
		# https://support.cpanel.net/hc/en-us/community/posts/19653628594071-Installing-PHP-PECL-imagick-fails-on-PHP-8-3
		# https://github.com/Imagick/imagick/pull/641
		imagick-3.7.0 \
		redis-6.0.2 \
	# https://secure.php.net/manual/en/opcache.installation.php
	&& docker-php-ext-enable \
		imagick \
		opcache \
		redis \
	&& extDir="$(php -r 'echo ini_get("extension_dir");')"; \
		[ -d "$extDir" ]; \
		runDeps="$( \
			scanelf --needed --nobanner --format '%n#p' --recursive "$extDir" \
				| tr ',' '\n' \
				| sort -u \
				| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
		)" \
	&& apk add --no-network --virtual .wordpress-phpexts-rundeps $runDeps \
	&& apk del --no-network .build-deps \
	&& rm -r /tmp/pear

# https://github.com/laradock/laradock/blob/master/php-fpm/Dockerfile
RUN set -e \
	&& curl -L -o /tmp/ioncube_loaders_lin_x86-64.tar.gz https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
	&& tar zxpf /tmp/ioncube_loaders_lin_x86-64.tar.gz -C /tmp \
	&& mv /tmp/ioncube/ioncube_loader_lin_${VERSION_PHP:0:3}.so $(php -r "echo ini_get('extension_dir');")/ioncube_loader.so \
	&& printf "zend_extension=ioncube_loader.so\n" > /usr/local/etc/php/conf.d/0ioncube.ini \
	&& rm -rf /tmp/* \
    && php -m | grep -oiE '^ionCube Loader$'

COPY ./error-logging.ini $PHP_INI_DIR/conf.d/
COPY ./opcache-recommended.ini $PHP_INI_DIR/conf.d/

COPY ./zz-docker.conf /usr/local/etc/php-fpm.d/

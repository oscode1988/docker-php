ARG PHP_VERSION="php:7.3.5-fpm-alpine"
FROM ${PHP_VERSION}

ARG TZ="Asia/Shanghai"
ARG PHP_EXTENSIONS="pdo_mysql,zip,mysql,mysqli,mbstring,gd,curl,redis,mongodb,swoole,imap,pcntl,soap,opcache,imagick,mcrypt,amqp,memcached"
ARG CONTAINER_PACKAGE_URL="mirrors.aliyun.com"


COPY ./extensions /tmp/extensions

# php7.4 gd库参数不一样
WORKDIR /tmp/extensions
RUN sed -i "s/dl-cdn.alpinelinux.org/${CONTAINER_PACKAGE_URL}/g" /etc/apk/repositories \
    \
    && apk add --no-cache --virtual .build-deps \
      autoconf \
      g++ \
      libtool \
      make \
      curl-dev \
      linux-headers \
    \
	&& chmod +x install.sh \
    && sh install.sh \
    && rm -rf /tmp/extensions \
    \
    && apk --no-cache add tzdata git \
    && cp "/usr/share/zoneinfo/$TZ" /etc/localtime \
    && echo "$TZ" > /etc/timezone \
    \
    && apk add gnu-libiconv --no-cache --repository http://${CONTAINER_PACKAGE_URL}/alpine/edge/community/ --allow-untrusted \
    \
    && curl -o /usr/bin/composer https://mirrors.aliyun.com/composer/composer.phar \
    && chmod +x /usr/bin/composer \
    && /usr/bin/composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/ \
    \
    && apk --no-cache add shadow && usermod -u 1000 www-data && groupmod -g 1000 www-data \
    && apk del .build-deps



ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

ENV COMPOSER_HOME=/tmp/composer

WORKDIR /www

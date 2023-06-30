FROM php:8.1.14-cli-alpine AS development

ENV WORKDIR /app

WORKDIR ${WORKDIR}

ENV BUILD_DEPS \
    autoconf \
    build-base \
    git \
    icu-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libzip-dev \
    libssh-dev \
    openssl-dev \
    libmemcached-dev \
    rabbitmq-c-dev \
    libpq-dev \
    zlib-dev \
    libmcrypt-dev \
    libxml2-dev \
    oniguruma-dev \
    ncurses \
    zip \
    unzip \
    linux-headers

RUN apk add --no-cache --virtual .ext-deps ${PHPIZE_DEPS} ${BUILD_DEPS} \
    # configure php extensions
    && docker-php-ext-configure \
        gd --with-jpeg --with-webp \
    && docker-php-ext-configure dom \
    && docker-php-ext-configure pdo_pgsql \
    && docker-php-ext-configure pdo_mysql \
    && docker-php-ext-configure zip \
    && docker-php-ext-configure bcmath \
    && docker-php-ext-configure opcache \
    && docker-php-ext-configure sockets \
    && docker-php-ext-configure intl \
    && docker-php-ext-configure exif \
    && docker-php-ext-configure pcntl \
    # install php extensions
    && docker-php-ext-install \
        dom xml zip gd pdo_pgsql pdo_mysql opcache sockets bcmath mbstring pdo intl exif pcntl \
    && pecl install \
        xdebug-3.2.0 amqp-1.11.0 mcrypt-1.0.5 mongodb-1.15.0 redis-5.3.7 \
    && docker-php-ext-enable \
        xdebug amqp mcrypt mongodb redis

# install composer
RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/local/bin --filename=composer --version=2.5.1 --quiet

# # PHP ini file
# COPY php/conf/php.ini-development /usr/local/etc/php/php.ini
# Xdebug config
COPY php/xdebug/xdebug.config.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.config.ini

# a stage where we remove development settings
FROM development AS production

RUN rm -f /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
&& rm -f /usr/local/etc/php/conf.d/docker-php-ext-xdebug.config.ini \
&& rm -f /usr/local/lib/php/extensions/*/xdebug.so

# PHP ini file
COPY php/conf/php.ini-production /usr/local/etc/php/php.ini
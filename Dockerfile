ARG FRANKENPHP_VERSION=1.4-php8.4-bookworm
ARG WORDPRESS_VERSION=6.7.1

# ----------------------------------------------------------------------------------------------------------------------
# WORDPRESS OFFICIAL IMAGE
# ----------------------------------------------------------------------------------------------------------------------
FROM wordpress:$WORDPRESS_VERSION AS wordpress_official

# ----------------------------------------------------------------------------------------------------------------------
# PHP BASE IMAGE
# ----------------------------------------------------------------------------------------------------------------------
FROM dunglas/frankenphp:$FRANKENPHP_VERSION AS php_base

ARG WP_CLI_VERSION=2.11.0

ENV COMPOSER_ALLOW_SUPERUSER=0
ENV COMPOSER_HOME=/tmp

# please do not change these after build
ENV APP_USER=app
ENV APP_USER_HOME=/home/app
ENV APP_USER_UID=1000
ENV APP_USER_GID=1000
ENV APP_HOME=/srv/app

# create the app user
RUN set -eu \
    && addgroup --gid $APP_USER_GID --system $APP_USER \
    && adduser \
        --disabled-password \
        --system \
        --home $APP_USER_HOME \
        --uid $APP_USER_UID \
        --gid $APP_USER_GID \
        --shell /sbin/nologin \
        $APP_USER

# install php debpendencies and configure extensions
RUN install-php-extensions \
        @composer \
        apcu \
        mysqli \
        zip \
        intl \
        gd \
        bcmath \
        opcache \
        exif \
        imagick

# get src recommneded config files
COPY --from=wordpress_official ${PHP_INI_DIR}/conf.d/* ${PHP_INI_DIR}/conf.d/

# WordPress CLI
ENV PAGER=more
RUN set -eu; \
    curl -sfLo /usr/bin/wp https://github.com/wp-cli/wp-cli/releases/download/v${WP_CLI_VERSION}/wp-cli-${WP_CLI_VERSION}.phar; \
    chmod +x /usr/bin/wp

# fix problem when using `security_opt: ['no-new-privileges:true']`
RUN setcap -r /usr/local/bin/frankenphp

# copy config files
RUN set -u; \
    ln -s "${PHP_INI_DIR}/php.ini-production" "${PHP_INI_DIR}/php.ini"

# setting up healtcheck
COPY .docker/php/docker-healthcheck.sh /usr/local/bin/docker-healthcheck
RUN chmod +x /usr/local/bin/docker-healthcheck
HEALTHCHECK --interval=10s --timeout=3s --retries=3 CMD ["docker-healthcheck"]

# update Caddyfile so it uses `web` instead of `public` for the root directory
RUN set -e; \
    sed -i 's#root \* public/$#root \* web/#' /etc/caddy/Caddyfile

USER $APP_USER
# the working directory will be used as a base path for Caddy root directive
WORKDIR $APP_HOME

# ----------------------------------------------------------------------------------------------------------------------
# PHP DEVELOPMENT
# ----------------------------------------------------------------------------------------------------------------------
FROM php_base AS php_dev

USER root

RUN set -e; \
    apt update; \
    apt install -y --no-install-recommends git; \
    rm -rf /var/lib/apt/lists/*

# add dev-only extennsions
RUN set -e; \
    install-php-extensions xdebug;

# copy config files
COPY .docker/.bashrc $APP_USER_HOME/.bashrc
COPY .docker/php/xdebug.ini "${PHP_INI_DIR}/conf.d/docker-php-ext-xdebug.ini"

USER $APP_USER

# ----------------------------------------------------------------------------------------------------------------------
# PHP BUILDER
# ----------------------------------------------------------------------------------------------------------------------
FROM php_base AS php_builder

COPY --chown="${APP_USER}:${APP_USER}" ./app/ "$APP_HOME"

# install composer packages and change permissions of some files
RUN set -eux; \
    composer install --no-dev --no-scripts --ansi --no-interaction --optimize-autoloader --working-dir="$APP_HOME"; \
    find "$APP_HOME" -type f -exec chmod 0664 {} + -o -type d -exec chmod 0775 {} +; \
    APP_ENV=prod php bin/console asset-map:compile

# ----------------------------------------------------------------------------------------------------------------------
# PHP PRODUCTION
# ----------------------------------------------------------------------------------------------------------------------
FROM php_base AS php_prod

ENV APP_ENV=prod

# copy application and config files
COPY --from=php_builder --chown="${APP_USER}:${APP_USER}" "$APP_HOME" "$APP_HOME"

USER $APP_USER
# the working directory will be used as a base path for Caddy root directive
WORKDIR $APP_HOME
# Use the PHP 8.2 FPM image as the base
FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libxpm-dev \
    zlib1g-dev \
    libzip-dev \
    libmariadb-dev \
    libxml2-dev \
    libldap2-dev \
    libsmbclient-dev \
    libcurl4-openssl-dev \
    cron \
    && rm -rf /var/lib/apt/lists/*

# Download and install the docker-php-extension-installer script
RUN curl -sSL https://github.com/mlocati/docker-php-extension-installer/releases/download/2.2.6/install-php-extensions -o /usr/local/bin/install-php-extensions \
    && chmod +x /usr/local/bin/install-php-extensions

# Install PHP extensions
RUN install-php-extensions \
    ctype \
    curl \
    dom \
    fileinfo \
    gd \
    hash \
    json \
    libxml \
    mbstring \
    openssl \
    posix \
    session \
    simplexml \
    xmlreader \
    xmlwriter \
    zip \
    zlib \
    pdo_mysql \
    intl \
    sodium \
    ldap \
    smbclient \
    ftp \
    imap \
    bcmath \
    gmp \
    exif \
    apcu \
    memcached \
    redis \
    imagick \
    sysvsem \
    opcache

# Copy crontab for system cron
COPY ./cron.sh /cron.sh
RUN chmod 0755 /cron.sh
COPY ./crontab /etc/cron.d/nextcloud
RUN chmod 0644 /etc/cron.d/nextcloud
RUN crontab /etc/cron.d/nextcloud

# Copy optimized php.ini-development and production
COPY ./php.ini-production /usr/local/etc/php/php.ini

# Set the working directory
WORKDIR /var/www/html

# Expose port 9000 for PHP-FPM
# EXPOSE 9000

# Start PHP-FPM
CMD ["bash", "-c", "php-fpm"]

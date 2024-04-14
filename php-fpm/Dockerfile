# Use the PHP 8.3 FPM image as the base
FROM php:8.3-fpm

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
    && rm -rf /var/lib/apt/lists/*

# Download and install the docker-php-extension-installer script
RUN curl -sSL https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions -o /usr/local/bin/install-php-extensions \
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
    sysvsem \
    opcache


# Copy optimized php.ini-development and production
COPY ./php.ini-production /usr/local/etc/php/php.ini

# Set the working directory
WORKDIR /var/www/html

# Expose port 9000 for PHP-FPM
# EXPOSE 9000

# Start PHP-FPM
CMD ["bash", "-c", "php-fpm"]

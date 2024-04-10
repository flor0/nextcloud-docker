FROM docker.io/library/nginx:latest

ENV NEXTCLOUD_DOMAIN=example.com
ENV NEXTCLOUD_PHP_FPM_HOST=php-fpm-nextcloud:9000
ENV NEXTCLOUD_MAX_UPLOAD_SIZE=512M

ADD nginx.conf.template /nginx.conf.template
ADD docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["sh", "-c", "/docker-entrypoint.sh"]

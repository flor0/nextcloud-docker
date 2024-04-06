# Nextcloud Docker

To get things set up:

- sudo chown -R www-data:www-data /your/nextcloud/webroot
- sudo chown -R www-data:www-data /your/nextcloud/data

Environment variables:
- DATA_DIR: Where your nextcloud data should be. The same as /your/nextcloud/data
- NEXTCLOUD_DIR: Where your nextcloud webroot should be. The same as /your/nextcloud/webroot
- MARIADB_ROOT_PASS and MARIADB_PASS: Password for your mariadb root user and the user called "nextcloud"
- TRAEFIK_CUSTOM_MIDDLEWARES: (optional) add additional middlewares if you have any
- DOMAIN: Set this to your domain like "\`example.com\`" or for more than one "\`example.com\`,\`another.com\`" **Don't forget the backticks**

For testing system cron run this yourself first:
- docker exec -u www-data php-fpm-nextcloud php --define apc.enable_cli=1 /var/www/html/cron.php
If it doesn't throw any errors, you're set. Add this to your crontab and forget it:
- */5 * * * * docker exec -u www-data php-fpm-nextcloud php --define apc.enable_cli=1 /var/www/html/cron.php
Make sure you enable system cron in your Nextcloud settings.
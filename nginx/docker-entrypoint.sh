#/usr/bin/env bash

# This implementation is adapted from the solution proposed here:
# https://stackoverflow.com/questions/21866477/nginx-use-environment-variables

# envsubst will take the input and replace all references to environment
# variables with their corresponding value. Because nginx uses the same
# '$' prefix for its internal variables, we should explicitly define the
# variables we want to replace rather than replacing all env vars.
envsubst '
$NEXTCLOUD_PHP_FPM_HOST
$NEXTCLOUD_DOMAIN
$NEXTCLOUD_MAX_UPLOAD_SIZE
' < /nginx.conf.template > /etc/nginx/nginx.conf

exec nginx -g 'daemon off;'

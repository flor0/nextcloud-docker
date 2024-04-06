![logo](https://cdn.rawgit.com/nextcloud/docker/071b888f7f689caa62c1498b6c61cb3599bcea2b/logo.svg)
# Nextcloud Dockerized

Currently existing "all-in-one" Nextcloud solutions using Docker are either unoptimized or lack many configuration options for advanced setup scenarios. This setup is close to an  optimized Nextcloud baremetal installation but with each component being dockerized.

With this project you **don't need to do manual configuration** such as
- installing webserver, php, redis
- installing php extensions
- optimizing web server and php for performance and large filesizes

You must still do:
- download nextcloud
- set permissions
- set your domain names and passwords in the config files
- (optional) add a cronjob on the host system 


Disclaimer:
This project is in no way associated with the official Nextcloud project. This project is maintained by me and is intended for expert use. If you want something simple to set up but with less configuration options consider the [Nextcloud All-In-One docker container](https://github.com/nextcloud/all-in-one#nextcloud-all-in-one). I do not take responsibility if you mess up your server, existing Nextcloud or lose your job because the Nextcloud calendar broke.

## Features
- An optimized version of php-fpm as described in the official Nextcloud [documentation](https://docs.nextcloud.com/server/28/admin_manual/installation/php_configuration.html).
- Redis preinstalled.
- Nginx preinstalled and already configured for Nextcloud as described in the [documentation](https://docs.nextcloud.com/server/28/admin_manual/installation/nginx.html).


## Install Guide

This assumes you already know how to install Nextcloud on a baremetal server or are familiar with the [documentation](https://docs.nextcloud.com/server/28/admin_manual/installation/index.html).

### Directories and file permissions
You need to create two directories. One where your Nextcloud webroot will be and another where you want the data to be. The location doesn't really matter. *In this example* we have both directories in **/your/nextcloud/root** bt you should choose your own. 

Next, download the latest archive containing Nextcloud from the official site [here](https://download.nextcloud.com/server/releases/latest.zip) and put it in `/your/nextcloud/root`.

Unzip the archive with `unzip latest.zip`. This will create the directory `/your/nextcloud/root/nextcloud`.

Create the directory where your Nextcloud data will be: `mkdir /your/nextcloud/root/data`

Set the correct owner for both directories:

`sudo chown -R www-data:www-data /your/nextcloud/root/nextcloud`

`sudo chown -R www-data:www-data /your/nextcloud/root/data`



### Setting up Docker Compose
You must set some environment variables. Create a **.env** file in the root of the cloned repo.
- DATA_DIR: Where your nextcloud data is. The same as /your/nextcloud/root/data
- NEXTCLOUD_DIR: Where your nextcloud webroot is. The same as /your/nextcloud/root/nextcloud
- MARIADB_ROOT_PASS and MARIADB_PASS: Password for your mariadb root user and the user called "nextcloud"
- TRAEFIK_CUSTOM_MIDDLEWARES: (optional) If you plan to use Traefik and want to add additional middlewares, if you have any
- DOMAIN: Set this to your domain like **"\`example.com\`"** or for more than one **"\`example.com\`,\`another.com\`"** without the double quotes. **Don't forget the backticks!**

### Building php-fpm
Because the official php-fpm images don't have and php extensions installed, we must do it ourselves.
Simply run this command from the root of the cloned repo:

`docker compose build php-fpm-nextcloud`

this will take a while.

### Installing Nextcloud

Run `docker compose up -d`. If something doesn't work try debugging it yourself of open an issue with the php-fpm and nginx logs attached.

Install Nextcloud how you usually would through the web interface. Use the MariaDB database and fill in the passwords you chose earlier. The database host is **mariadb-nextcloud:3306**

### Editing the Nextcloud config
Edit `/your/nextcloud/root/nextcloud/config/config.php` and add the following optimizations:

```
'memcache.local' => '\\OC\\Memcache\\APCu',
'maintenance_window_start' => 1,
'filelocking.enabled' => true,
'memcache.locking' => '\OC\Memcache\Redis',
'redis' => array(
    'host' => 'redis-nextcloud',
    'port' => 6379,
    'timeout' => 0.0,
),
```

### Editing nginx.conf
You may also have to replace `example.com` with your own domain or multiple domains in the nginx.conf file.

### Enabling system cron (optional)
Nextcloud must perform background tasks. The best way to do that is to use cron. However, on docker this is not easily doable. Here the host will perform the cronjobs required.

For testing if system cron works run this yourself first:

`docker exec -u www-data php-fpm-nextcloud php --define apc.enable_cli=1 /var/www/html/cron.php`

If it doesn't throw any errors, you're set. Add this to your crontab:

`*/5 * * * * docker exec -u www-data php-fpm-nextcloud php --define apc.enable_cli=1 /var/www/html/cron.php`

Make sure you enable system cron in your Nextcloud admin panel.

### Adding Traefik (optional)
<details>
<summary>Instructions</summary>

If you want to run Nextcloud behind a reverse proxy here's how to set it up with Traefik. This assumes you already have Traefik up and running and created a docker network for it called *traefik*.
Add the environment variable as mentioned above. 

*Replace* the entire nginx service with this in the docker-compose.yml and add the traefik network:
```
nginx:
    container_name: nginx-nextcloud
    image: nginx:latest
    volumes:
      - ${NEXTCLOUD_DIR}:/var/www/html
      - ${DATA_DIR}:/data
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    labels:
      - "traefik.enable=true"
      - "traefik.docker.network=traefik"

      - "traefik.http.routers.nginx-http.rule=Host(${DOMAIN})"
      - "traefik.http.routers.nginx-http.entrypoints=web"
      - "traefik.http.routers.nginx-http.middlewares=nextcloud-https-redirect@docker,nc-header@docker,nextcloud_redirectregex@docker${TRAEFIK_CUSTOM_MIDDLEWARES}"

      - "traefik.http.routers.nginx-https.rule=Host(${DOMAIN})"
      - "traefik.http.routers.nginx-https.tls=true"
      - "traefik.http.routers.nginx-https.tls.certresolver=myresolver"
      - "traefik.http.routers.nginx-https.entrypoints=websecure"
      - "traefik.http.routers.nginx-https.middlewares=nc-header@docker,nextcloud_redirectregex@docker${TRAEFIK_CUSTOM_MIDDLEWARES}"
      - "traefik.http.middlewares.nc-header.headers.stsSeconds=15552001"

      # MIDDLEWARES
      - "traefik.http.middlewares.nextcloud_redirectregex.redirectregex.permanent=true"
      - "traefik.http.middlewares.nextcloud_redirectregex.redirectregex.regex=https://(.*)/.well-known/(?:card|cal)dav"
      - "traefik.http.middlewares.nextcloud_redirectregex.redirectregex.replacement=https://$${1}/remote.php/dav"

      # HTTP->HTTPS redirect
      - "traefik.http.middlewares.nextcloud-https-redirect.redirectscheme.scheme=https"
      - "traefik.http.middlewares.nextcloud-https-redirect.redirectscheme.permanent=true"
      # Traefik service
      - "traefik.http.routers.nginx-https.service=nextcloud-service"
      - "traefik.http.services.nextcloud-service.loadbalancer.server.port=80"
    networks:
      - nextcloud
      - traefik
    depends_on:
      - php-fpm-nextcloud
      - redis-nextcloud
      - mariadb-nextcloud

networks:
    traefik:
        external: true
```
Get the internal IP address range of your Traefik network with `docker network inspect traefik`. For example this will give you a subnet like 192.168.173.0/20
Add this to your `/your/nextcloud/root/nextcloud/config/config.php`:
```
'trusted_proxies' => 
  array (
    0 => 'INSERT TRAEFIK IP SUBNET HERE for our example 192.168.173.0/20',
  ),
```

</details>


### Migrating from existing Nextcloud
To migrate you follow the steps described in the official [docs](https://docs.nextcloud.com/server/28/admin_manual/maintenance/migrating.html). The only difference here is importing the database backup into MariaDB running in the Docker Container. The way I did it is I exposed a port to MariaDB in the docker compose file and I ran something like `mysql -h [localhost:PORT HERE] -u nextcloud -pPASSWORD HERE nextcloud < database.bak` to import the backed up database.
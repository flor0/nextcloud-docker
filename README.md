![logo](https://cdn.rawgit.com/nextcloud/docker/071b888f7f689caa62c1498b6c61cb3599bcea2b/logo.svg)
# Nextcloud Dockerized

Currently existing "all-in-one" Nextcloud solutions using Docker are either unoptimized or lack many configuration options for advanced setup scenarios. This setup is close to an  optimized Nextcloud baremetal installation but with each component being dockerized.

With this project you **don't need to do manual configuration** such as...
- installing webserver, php, redis
- installing php extensions
- optimizing web server and php for performance and large filesizes

However, you must still...
- download nextcloud
- set permissions
- set your domain names and passwords in the config files

...or use the provided Ansible playbook to set things up for you.


Disclaimer:
This project is in no way associated with the official Nextcloud project. This project is maintained by me and is intended for expert use. If you want something simple to set up but with less configuration options consider the [Nextcloud All-In-One docker container](https://github.com/nextcloud/all-in-one#nextcloud-all-in-one). I do not take responsibility if you mess up your server, existing Nextcloud or lose your job because the Nextcloud calendar broke.

## Features
- An optimized version of php-fpm as described in the official Nextcloud [documentation](https://docs.nextcloud.com/server/28/admin_manual/installation/php_configuration.html).
- Nginx preinstalled and already configured for Nextcloud as described in the [documentation](https://docs.nextcloud.com/server/28/admin_manual/installation/nginx.html).
- Redis preinstalled.
- Nextcloud system cronjob preconfigured.

## Install Guide

If you use Ansible, you can use the provided playbook.

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


### Adding Traefik (optional)
Check out the *traefik* branch for instructions 


### Migrating from existing Nextcloud
To migrate you follow the steps described in the official [docs](https://docs.nextcloud.com/server/28/admin_manual/maintenance/migrating.html). The only difference here is importing the database backup into MariaDB running in the Docker Container. The way I did it is I exposed a port to MariaDB in the docker compose file and I ran something like `mysql -h localhost -P [PORT] -u nextcloud -p[PASSWORD] nextcloud < database.bak` to import the backed up database.

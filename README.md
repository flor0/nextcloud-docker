![logo](https://cdn.rawgit.com/nextcloud/docker/071b888f7f689caa62c1498b6c61cb3599bcea2b/logo.svg)
# Nextcloud Dockerized - Traefik

To run the same setup behind the traefik reverse proxy you must follow a few additional steps.
Make sure you clone the *traefik* branch since it's mostly configured already.

This assumes you already have Traefik up and running and created a docker network for it called *traefik*.

## Environment variables

- **TRAEFIK_CUSTOM_MIDDLEWARES**: If you want to add additional middlewares, if you have any
- **DOMAIN**: Set this to your domain like **"\`example.com\`"** or for more than one **"\`example.com\`,\`another.com\`"** without the double quotes. **Don't forget the backticks!**

## Adding Traefik

Get the internal IP address range of your Traefik network with `docker network inspect traefik`. For example this will give you a subnet like 192.168.173.0/20
Add this to your `/your/nextcloud/root/nextcloud/config/config.php`:
```
'trusted_proxies' => 
  array (
    0 => 'INSERT TRAEFIK IP SUBNET HERE for our example 192.168.173.0/20',
  ),
```
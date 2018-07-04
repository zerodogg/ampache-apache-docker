# ampache-apache

Docker container for Ampache, a web based audio/video streaming application and
file manager allowing you to access your music & videos from anywhere, using
almost any internet enabled device.

This is image does not come with a database. It is suggested that you install
a separate container (for instance [the official
mariadb](https://hub.docker.com/_/mariadb/) image) and then either `--link` the
container or put it on the same network as the ampache container. Then you can
connect to it from your ampache container.

## Quick usage
```bash
docker run --link mariadb:mariadb --name=ampache -d -v /path/to/your/music:/media:ro -p 80:80 zerodogg/ampache
```
Then visit the container in a web browser to complete the setup. When prompted
for database, provide the credentials for the database you `--link`ed or that
is on the same network (the link name, or the name of the database container).

## Image details

The image is based upon the upstream `php` image (7.1 on Debian stretch at the
moment). It exposes ampache (via apache and mod_php) on port `80`. If you want
to run it on https, you can achieve this by having a reverse proxy in front of
it. The [nginx-proxy](https://hub.docker.com/r/jwilder/nginx-proxy/) container
paired with
[letsencrypt-nginx-proxy-companion](https://hub.docker.com/r/jrcs/letsencrypt-nginx-proxy-companion/)
works great along with this container and is simple to set up.

## Volumes

All of these are marked as a volume by default.

`/media` is the suggested location to mount your music collection to. This can
be read-only.

`/var/www/html/config` is where the config files reside.

`/var/www/html/themes` is where custom themes reside. You only need to worry
about this one if you actually want to use custom themes.

## Auto-updating the library

The container will, by default, auto-update the ampache library. However, since
this uses inotify, and the default max number of files allowed to be monitored
on most systems is rather low (8192). Thus you will need to increase the number
of watches allowed by writing to /proc/sys/fs/inotify/max_user_watches or
setting the sysctl fs.inotify.max_user_watches if you want the container to use
inotify. If the inotify max_user_watches is set to the default 8192, the
container will not monitor the library for changes, but trigger an update of
the library every 24 hours.

If you are sure that your library is small enough for 8192 watches to be
enough, you can set the environment variable `AMPACHE_FORCE_INOTIFY` to any
value, and it will bypass the max_user_watches check.

## Thanks to
- @arielelkin for the initial work on this container
- @ericfrederich for his original work
- @velocity303 and @goldy for the other ampache-docker inspiration

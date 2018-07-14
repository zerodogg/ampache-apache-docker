# ampache-apache

Docker container for [Ampache](http://ampache.org), a web based audio/video
streaming application and file manager allowing you to access your music &
videos from anywhere, using almost any internet enabled device.

This image ships ampache on top of mod_php on Apache. It is listening on
port 80. It does not come with a database. It is suggested that you install a
separate container (for instance [the official
mariadb](https://hub.docker.com/_/mariadb/) image) and then either `--link` the
container or put it on the same docker network as the ampache container. Then
you can connect to it from your ampache container.

## Quick usage

### docker run

```bash
docker run --link mariadb:mariadb --name=ampache -d -v /path/to/your/music:/media:ro -p 80:80 zerodogg/ampache-apache
```

Then visit the container in a web browser to complete the setup. When prompted
for database, provide the credentials for the database you `--link`ed or that
is on the same network (using the link name, or the name of the database
container as the hostname).

### docker-compose

Clone the git repository from https://gitlab.com/zerodogg/ampache-docker or
download the [docker-compose.yml file](https://gitlab.com/zerodogg/ampache-docker/raw/master/docker-compose.yml).
Then run ``docker-compose up`` from the directory that you downloaded the
`docker-compose.yml` file to.

You should probably change the MYSQL_ROOT_PASSWORD environment variable in the
docker-compose file to a non-default value.

Then visit the container in a web browser to complete the setup.

## Image details

The image is based upon the upstream `php` image (7.1 on Debian stretch at the
moment). It exposes ampache (via apache and mod_php) on port `80`. If you want
to run it on https (or run several webapps on the same host), you can achieve
this by having a reverse proxy in front of it. The
[nginx-proxy](https://hub.docker.com/r/jwilder/nginx-proxy/) container paired
with
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

The container will auto-update the ampache library. It uses inotify to monitor
for changes. If your library is larger than the number of permitted inotify
watches (by default 8192), however, it will fall back to just auto-updating the
library every 24 hours instead. It will output a message visible in the docker
logs when the container starts if the number of inotify watches is too low.

If it is too low for your library and you want to use auto-updating, you can
increase the allowed number of inotify watches by writing to
`/proc/sys/fs/inotify/max_user_watches` or setting the sysctl
`fs.inotify.max_user_watches` (since `/proc` is read-only in the container, it
can't do that on its own).

## Thanks to
- @arielelkin for the initial work on this container
- @ericfrederich for his original work
- @velocity303 and @goldy for the other ampache-docker inspiration

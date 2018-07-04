#!/bin/bash

# Update the .dist file in the volume, so that we *KNOW* that it is up-to-date
# with the ampache version
sudo -u www-data cp /ampache.cfg.php.dist /var/www/html/config/ampache.cfg.php.dist

# Start a background process to auto-update the library
(
    if [ "$(cat /proc/sys/fs/inotify/max_user_watches)" == "8192" ] && [ "$AMPACHE_FORCE_INOTIFY" == "" ]; then
        echo "********"
        echo "NOTICE:"
        echo "The maximum number of inotify watches is very small (the default 8192)."
        echo "This is not enough for any large media collection. If you want to"
        echo "auto-update the library on changes, you must increase the number of"
        echo "inotify watches by writing to /proc/sys/fs/inotify/max_user_watches or"
        echo "setting the sysctl value fs.inotify.max_user_watches. The container can't"
        echo "do this on its own since its /proc is read-only."
        echo ""
        echo "Falling back to running an update approximately every 24 hours."
        echo "********"
        while true; do
            sleep 24h
            sudo -u www-data php /var/www/html/bin/catalog_update.inc -a
        done
    else
        while true; do
            inotifywait -r /media
            sudo -u www-data php /var/www/html/bin/catalog_update.inc -a
            sleep 30
        done
    fi
) &

# run this in the foreground so Docker won't exit
exec /usr/local/bin/apache2-foreground

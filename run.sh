#!/bin/bash

# Update the .dist file in the volume, so that we *KNOW* that it is up-to-date
# with the ampache version
sudo -u www-data cp /ampache.cfg.php.dist /var/www/html/config/ampache.cfg.php.dist

# Start a background process to auto-update the library
(
    # By default, use inotifywait to watch the library
    while true; do
        inotifywait -r /media &>/dev/null
        # If inotifywait returns 1 then the inotify limit is too small
        if [ "$?" == "1" ]; then
            break
        fi
        sudo -u www-data php /var/www/html/bin/catalog_update.inc -a
        sleep 30
    done
    # This is the fallback method when the number of inotify watches is too small.
    # It simply auto-updates the library once every 24 hours
    watchesNo="$(cat /proc/sys/fs/inotify/max_user_watches)"
    echo "********"
    echo "NOTICE:"
    echo "The maximum number of inotify watches ($watchesNo) is too small for your"
    echo "media collection. If you want to auto-update the library on changes, you must"
    echo "increase the permitted number of inotify watches by writing to"
    echo "/proc/sys/fs/inotify/max_user_watches or setting the sysctl setting"
    echo "fs.inotify.max_user_watches and then restart the container."
    echo ""
    echo "Falling back to running an update approximately every 24 hours."
    echo "********"
    while true; do
        sleep 24h
        sudo -u www-data php /var/www/html/bin/catalog_update.inc -a
    done
) &

# run this in the foreground so Docker won't exit
exec /usr/local/bin/apache2-foreground

#!/bin/bash

if [[ ! -f /var/www/html/config/ampache.cfg.php ]]; then
    mv /var/temp/ampache.cfg.php.dist /var/www/html/config/ampache.cfg.php.dist
    chown www-data:www-data /var/www/html/config/ampache.cfg.php
fi

# Start a process to watch for changes in the library with inotify
(
while true; do
    inotifywatch /media
    sudo -u www-data php /var/www/html/bin/catalog_update.inc -a
    sleep 30
done
) &

# run this in the foreground so Docker won't exit
exec /usr/local/bin/apache2-foreground

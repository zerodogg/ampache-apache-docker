#!/bin/bash

# Update the .dist file in the volume, so that we *KNOW* that it is up-to-date
# with the ampache version
sudo -u www-data cp /ampache.cfg.php.dist /var/www/html/config/ampache.cfg.php.dist

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

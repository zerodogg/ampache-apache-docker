#!/bin/bash

if [[ ! -f /var/www/html/config/ampache.cfg.php ]]; then
    sudo -u www-data cp /ampache.cfg.php.dist /var/www/html/config/ampache.cfg.php.dist
fi
# Update the .dist file in the volume, so that we *KNOW* that it is up-to-date
# with the ampache version
sudo -u www-data cp /ampache.cfg.php.dist /var/www/html/config/ampache.cfg.php.dist
sudo -u www-data perl -pi -E 's{^}{; WARNING: This file will be overwitten during updates. Edit ampache.cfg.php instead\n}' /var/www/html/config/ampache.cfg.php.dist

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

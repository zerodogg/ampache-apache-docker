FROM php:7.1-apache-stretch
MAINTAINER zerodogg

# The ampache version
ARG version=3.8.8

    # Fetch apt repo metadata
RUN apt-get update && \
    # Install debs needed to add the VLC repo
    DEBIAN_FRONTEND=noninteractive apt-get -y install wget sudo gnupg2 && \
    # Add the VLC repo to get up-to-date codecs
    echo 'deb http://download.videolan.org/pub/debian/stable/ /' >> /etc/apt/sources.list && \
    echo 'deb-src http://download.videolan.org/pub/debian/stable/ /' >> /etc/apt/sources.list && \
    wget -O - https://download.videolan.org/pub/debian/videolan-apt.asc|sudo apt-key add - && \
    apt-get update && \
    # Install libraries/codecs and tools that ampache needs
    DEBIAN_FRONTEND=noninteractive apt-get -y install inotify-tools lame libvorbisfile3 libvorbisenc2 vorbis-tools flac libmp3lame0 libavcodec-extra* libtheora0 libvpx4 libav-tools git libpng-dev libjpeg-dev libfreetype6-dev libjpeg62-turbo && \
    # Install PHP extensions (GD+MySQL)
    docker-php-ext-configure gd --with-freetype-dir=/usr --with-png-dir=/usr --with-jpeg-dir=/usr && \
    docker-php-ext-install pdo_mysql gd  && \
    # Install composer (used to install PHP library dependencies)
    php -r "readfile('https://getcomposer.org/installer');" | php && \
    mv composer.phar /usr/local/bin/composer && \
    # Clean up
    apt-get clean && \
    DEBIAN_FRONTEND=noninteractive apt-get -y purge libpng-dev libjpeg-dev libfreetype6-dev && \
    rm -rf /var/lib/apt/lists/*

    # Download, extract and install ampache
RUN wget -O /opt/ampache.tar.gz https://github.com/ampache/ampache/archive/$version.tar.gz && \
    rm -rf /var/www/html/* && \
    tar -C /var/www/html/ -xf /opt/ampache.tar.gz ampache-$version --strip=1 && \
    # Fix ownership
    chown -R www-data /var/www/html/ && \
    # Install dependencies with composer
    cd /var/www/html && sudo -u www-data composer install --prefer-source --no-interaction --optimize-autoloader && \
    # Remove git repo data that we don't need
    find /var/www/html/lib/vendor -name .git -type d -print0 |xargs -0 -- rm -rf && \
    # Move all the htaccess files into place
    for dir in $(find /var/www/html -name .htaccess.dist -print0|xargs -0 dirname); do cp $dir/.htaccess.dist $dir/.htaccess;done && \
    # Enable mod_rewrite
    ln -sf /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load && \
    # Modify the .dist config:
    # - comment out database_name and database_username by default
    # - set the default database_hostname to "mysql"
    perl -pi -E 's{^(database_username|database_name)}{;$1}g; s{^database_hostname\s*=.*}{database_hostname = mysql}' /var/www/html/config/ampache.cfg.php.dist && \
    # Copy the .dist somewhere outside of the /config tree, so that we can
    # update it when needed
    cp /var/www/html/config/ampache.cfg.php.dist /ampache.cfg.php.dist && \
    # Clean up
    rm -f /opt/ampache.tar.gz && \
    DEBIAN_FRONTEND=noninteractive apt-get -y purge --auto-remove g++-6 gcc-6 dpkg-dev libc6-dev libgcc-6-dev libstdc++-6-dev linux-libc-dev zlib1g-dev libc-dev-bin

ADD run.sh /run.sh
RUN chmod a+x /run.sh

VOLUME ["/media"]
VOLUME ["/var/www/html/config"]
VOLUME ["/var/www/html/themes"]
EXPOSE 80

CMD ["/run.sh"]

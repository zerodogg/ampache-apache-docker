FROM php:7.1-apache-stretch
LABEL maintainer="Eskild Hustvedt code@zerodogg.org"

# The ampache version
ARG version=3.8.8
# Checksum for the ampache tarball
ARG tarballChecksum=4aa010b6bb42a192d6e2408265a78e738a356c08bfb43464fbc6e6375d8cdc9e4701280db0b21f73a1302b2792f9474c6dc5c7808c977a29aab2047a80caebfc
# The composer version
ARG composerVersion=1.6.5
# The composer checksum
ARG composerChecksum=a94a9497ad45cf5bfb2cd4669c73f8cd3b86d0d97a13828ee3b48e8675972293cec898bfb977e55cddf26c5261c5e039310b821d2d5eb4fa046ec5e9e317b21e

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
    # Clean up
    apt-get clean && \
    DEBIAN_FRONTEND=noninteractive apt-get -y purge libpng-dev libjpeg-dev libfreetype6-dev && \
    rm -rf /var/lib/apt/lists/*

    # Download, extract and install ampache
RUN wget -O /opt/ampache.tar.gz https://github.com/ampache/ampache/archive/$version.tar.gz && \
    /usr/bin/test "`sha512sum /opt/ampache.tar.gz|cut -d' ' -f 1`" = "$tarballChecksum" && \
    rm -rf /var/www/html/* && \
    tar -C /var/www/html/ -xf /opt/ampache.tar.gz ampache-$version --strip=1 && \
    # Fix ownership
    chown -R www-data /var/www/html/ && \
    # Install composer (used to install PHP library dependencies)
    wget -O /usr/local/bin/composer "https://github.com/composer/getcomposer.org/raw/HEAD/web/download/$composerVersion/composer.phar" && \
    /usr/bin/test "`sha512sum /usr/local/bin/composer|cut -d' ' -f 1`" = "$composerChecksum" && \
    chmod 755 /usr/local/bin/composer && \
    # Install dependencies with composer
    cd /var/www/html && sudo -u www-data composer install --prefer-source --no-interaction --optimize-autoloader && \
    # Remove composer
    rm -f /usr/local/bin/composer && \
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

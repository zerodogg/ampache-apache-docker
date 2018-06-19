FROM php:7.1-apache-stretch
MAINTAINER zerodogg

# The ampache version
ARG version=3.8.8

ADD ampache.cfg.php.dist /var/temp/ampache.cfg.php.dist

    # First update the contents of the image
RUN apt-get update && \
    apt-get -y upgrade && \
    # Install debs needed to add the VLC repo
    DEBIAN_FRONTEND=noninteractive apt-get -y install wget sudo gnupg2 && \
    # Add the VLC repo to get up-to-date codecs
    echo 'deb http://download.videolan.org/pub/debian/stable/ /' >> /etc/apt/sources.list && \
    echo 'deb-src http://download.videolan.org/pub/debian/stable/ /' >> /etc/apt/sources.list && \
    wget -O - https://download.videolan.org/pub/debian/videolan-apt.asc|sudo apt-key add - && \
    apt-get update && \
    # Install libraries/codecs and tools that ampache needs
    DEBIAN_FRONTEND=noninteractive apt-get -y install inotify-tools lame libvorbis-dev vorbis-tools flac libmp3lame-dev libavcodec-extra* libtheora-dev libvpx-dev libav-tools git libpng-dev libjpeg-dev libfreetype6-dev && \
    # Install PHP extensions (GD+MySQL)
    docker-php-ext-configure gd --with-freetype-dir=/usr --with-png-dir=/usr --with-jpeg-dir=/usr && \
    docker-php-ext-install pdo_mysql gd  && \
    # Install composer (used to install PHP library dependencies)
    php -r "readfile('https://getcomposer.org/installer');" | php && \
    mv composer.phar /usr/local/bin/composer && \
    # Clean up
    apt-get clean

    # Download, extract and install ampache
RUN wget -O /opt/ampache.tar.gz https://github.com/ampache/ampache/archive/$version.tar.gz && \
    rm -rf /var/www/html/* && \
    tar -C /var/www/html/ -xf /opt/ampache.tar.gz ampache-$version --strip=1 && \
    # Fix ownership
    chown -R www-data /var/www/html/ && \
    # Install dependencies with composer
    cd /var/www/html && sudo -u www-data composer install --prefer-source --no-interaction && \
    # Move all the htaccess files into place
    for dir in $(find /var/www/html -name .htaccess.dist -print0|xargs -0 dirname); do cp $dir/.htaccess.dist $dir/.htaccess;done && \
    # Enable mod_rewrite
    ln -sf /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load && \
    # Clean up
    rm -f /opt/ampache.tar.gz && \
    DEBIAN_FRONTEND=noninteractive apt-get -y purge libvorbis-dev libmp3lame-dev libtheora-dev libvpx-dev libpng-dev libjpeg-dev libfreetype6-dev

ADD run.sh /run.sh
RUN chmod a+x /run.sh

VOLUME ["/media"]
VOLUME ["/var/www/html/config"]
VOLUME ["/var/www/html/themes"]
EXPOSE 80

CMD ["/run.sh"]

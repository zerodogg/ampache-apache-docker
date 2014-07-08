FROM ubuntu:14.04
MAINTAINER Eric L. Frederich

# Lets get an up to date environment
RUN apt-get update
RUN apt-get -y upgrade

# Need this environment variable otherwise mysql will prompt for passwords
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-server apache2 wget php5 php5-curl php5-mysqlnd pwgen

# For local testing / faster builds
# COPY 3.7.0.tar.gz /opt/3.7.0.tar.gz
ADD https://github.com/ampache/ampache/archive/3.7.0.tar.gz /opt/3.7.0.tar.gz

# Check known md5 of the release we downloaded
RUN cd /opt && TMP=$(md5sum 3.7.0.tar.gz | cut -c-32) && [ "$TMP" = "10e127f616e802340038e460a990586c" ]

# extraction / installation
RUN tar -C /opt -xf /opt/3.7.0.tar.gz
RUN chown -R www-data /opt/ampache-3.7.0
RUN cd /var/www/html && ln -s /opt/ampache-3.7.0 ampache

# setup mysql like this project does it: https://github.com/tutumcloud/tutum-docker-mysql
# Remove pre-installed database

RUN rm -rf /var/lib/mysql/*
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ENV MYSQL_PASS **Random**
# Add VOLUMEs to allow backup of config and databases
VOLUME  ["/etc/mysql", "/var/lib/mysql"]

CMD ["/run.sh"]

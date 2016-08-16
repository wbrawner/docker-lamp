FROM debian:jessie

# Install necessary programs
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y apache2 libapache2-mod-php5 \
lsb-release php5 php5-mysql php5-mcrypt php5-curl php5-gd php5-xsl php5-intl \
phpmyadmin vim wget curl git cron

# Configure apache
COPY ./config/apache2.conf /etc/apache2/apache2.conf
RUN chmod 644 /etc/apache2/apache2.conf
RUN a2enmod rewrite

# Configure MySQL
RUN wget "http://dev.mysql.com/get/mysql-apt-config_0.7.3-1_all.deb" 
RUN dpkg -i mysql-apt-config_0.7.3-1_all.deb && apt-get update && apt-get \
install -y mysql-server
#COPY ./config/my.cnf /etc/mysql/my.cnf
#RUN chmod 644 /etc/mysql/my.cnf
#RUN service mysql restart && mysql -u root --execute="CREATE USER admin IDENTIFIED BY ''; GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' IDENTIFIED BY '';"
EXPOSE 3306

# Configure PHP
COPY ./config/php.ini /etc/php5/apache2/php.ini
RUN chmod 644 /etc/php5/apache2/php.ini

# Configure PHPMyAdmin
COPY ./config/config.inc.php /etc/phpmyadmin/config.inc.php
RUN chmod 644 /etc/phpmyadmin/config.inc.php

# Install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
php composer-setup.php && \
php -r "unlink('composer-setup.php');"

# Install modman
RUN wget -q --no-check-certificate -O - https://raw.github.com/colinmollenhour/modman/master/modman-installer | bash && \
mv ~/bin/modman /usr/local/bin/modman

# Start the web server
ENV APACHE_LOCK_DIR=/var/lock/apache2
ENV APACHE_PID_FILE=/var/run/apache2/apache2.pid
ENV APACHE_RUN_USER=www-data
ENV APACHE_RUN_GROUP=www-data
ENV APACHE_LOG_DIR=/var/log/apache2

# Fire up the image!
WORKDIR /var/www/html
ENTRYPOINT service cron start; service mysql start; apache2 -DFOREGROUND

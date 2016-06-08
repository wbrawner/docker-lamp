FROM debian:jessie

# Install necessary programs
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y apache2 libapache2-mod-php5 \
mysql-server php5 php5-mysql php5-mcrypt php5-curl php5-gd phpmyadmin vim \
wget curl git

# Configure apache
COPY ./config/apache2.conf /etc/apache2/apache2.conf
RUN chmod 644 /etc/apache2/apache2.conf
RUN a2enmod rewrite

# Configure MySQL
COPY ./config/my.cnf /etc/mysql/my.cnf
RUN chmod 644 /etc/mysql/my.cnf
RUN service mysql start && mysql -u root --execute="GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '';"
EXPOSE 3306

# Configure PHPMyAdmin
COPY ./config/config.inc.php /etc/phpmyadmin/config.inc.php
RUN chmod 644 /etc/phpmyadmin/config.inc.php

# Install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('SHA384', 'composer-setup.php') === && \ '070854512ef404f16bac87071a6db9fd9721da1684cd4589b1196c3faf71b9a2682e2311b36a5079825e155ac7ce150d') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
php composer-setup.php && \
php -r "unlink('composer-setup.php');"

# Install magerun
RUN wget https://files.magerun.net/n98-magerun.phar && \
    mv n98-magerun.phar /usr/bin/ && \
    echo 'alias magerun="php -f /usr/bin/n98-magerun.phar --"' >> /root/.bashrc

# Install Accolade Magerun Tools
RUN mkdir -p /usr/local/share/n98-magerun/modules && \
git clone https://github.com/Accolades/MagerunTools.git /usr/local/share/n98-magerun/modules/MagerunTools

# Install Magento Mess Detector
RUN git clone https://github.com/AOEpeople/mpmd.git /usr/local/share/n98-magerun/modules/mpmd

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
ENTRYPOINT service mysql start; apache2 -DFOREGROUND

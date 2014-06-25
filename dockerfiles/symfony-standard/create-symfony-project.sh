#!/bin/bash

if [ ! -d /var/www/symfony-standard ];
then
    # Install composer
    cd /tmp && curl -sS https://getcomposer.org/installer | php

    # Create new project based on symfony standard edition using composer
    php /tmp/composer.phar create-project symfony/framework-standard-edition /var/www/symfony-standard "2.5.*"
fi

chown -R www-data /var/www/symfony-standard

chmod 777 -R /var/www/symfony-standard/app/logs
chmod 777 -R /var/www/symfony-standard/app/cache
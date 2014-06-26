#!/bin/bash

echo 'installing symfony standard edition'

cat /tmp/create-symfony-project.sh
. /tmp/create-symfony-project.sh
chown -R www-data /var/www/symfony-standard
chmod -R 777 /var/www/symfony-standard/app/logs
chmod -R 777 /var/www/symfony-standard/app/cache
sleep 10

echo 'starting nginx'
/etc/init.d/php-nginx start &
sleep 5

echo 'testing elasticsearch / nginx'
curl -XGET 'http://'$SYMFONY__ELASTICSEARCH__PORT_9200_TCP_ADDR':9200'
curl -XGET 'http://localhost' -v

tail -n100 /var/log/nginx/access.log
tail -n100 /var/log/nginx/error.log

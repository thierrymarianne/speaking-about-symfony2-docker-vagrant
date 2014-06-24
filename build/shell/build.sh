#!/bin/bash

VERBOSE_INFO=1

############
# Base
############

# Install password generation tool
apt-get install -f --force-yes pwgen

COLOR_PREFIX='\033'

GREEN=$COLOR_PREFIX'[31m'
BLUE=$COLOR_PREFIX'[36m'
WHITE=$COLOR_PREFIX'[0m'

INFO=$BLUE'[INFO] '

if [ $VERBOSE_INFO -gt 0 ]
then
    echo -e $INFO'About to stop running containers before removing them'$WHITE
fi

SECTION=01-la-brute
WORKING_DIR=/home/vagrant/package-app/$SECTION
REPOSITORY=afup

# Stop containers but toran container before removing them
for CONTAINER_ID in `docker ps -a | grep "$REPOSITORY\|squid" | awk '{print $1}'`; do
    docker stop $CONTAINER_ID && docker rm $CONTAINER_ID
done;

# Select application name
if [[ -z "$1" ]];
then
    APP_NAME='symfony2'
else
    APP_NAME=$1
fi

DNS_ENTRIES=`cat /etc/resolv.conf`

# Add DNS entries

if [[ $(echo $DNS_ENTRIES | grep '8.8.8.8') ]]
then
	echo 'nameserver 8.8.8.8' >> /etc/resolv.conf
fi

if [[ $(echo $DNS_ENTRIES | grep '8.8.4.4') ]]
then
	echo 'nameserver 8.8.4.4' >> /etc/resolv.conf
fi

cd $WORKING_DIR

############
# Elasticsearch
############

if [ ! -d ../$SECTION/elasticsearch/var/lib/elasticsearch ]
then
	mkdir -p ../$SECTION/elasticsearch/var/lib/elasticsearch
fi

# Clean up
rm -r ../$SECTION/elasticsearch/var/lib/elasticsearch/* -f

# Set write permissions
find ../$SECTION/elasticsearch/var/lib/elasticsearch -not -path . -exec chmod og+w {} \;
find ../$SECTION/elasticsearch/var/lib/elasticsearch -not -path . -exec chown vagrant {} \;

# Build Elasticsearch data volume container
cd $WORKING_DIR/data;
docker build -t $REPOSITORY/elasticsearch-data-volume:0.1 .

# Build Elasticsearch server container
cd $WORKING_DIR/elasticsearch;
docker build -t $REPOSITORY/elasticsearch:0.1 .

# Run Elasticsearch data volume container
cd $WORKING_DIR
docker run -d --name elasticsearch-data-volume \
-p :22 \
-v `pwd`/elasticsearch/var/lib/elasticsearch:/var/lib/elasticsearch \
$REPOSITORY/elasticsearch-data-volume:0.1

# Run Elasticsearch server container in detached mode
cd $WORKING_DIR
docker run -d -p 9200:9200 \
--name elasticsearch-server \
--volumes-from elasticsearch-data-volume \
-v `pwd`/elasticsearch/var/lib/elasticsearch:/var/lib/elasticsearch \
$REPOSITORY/elasticsearch:0.1 || exit $?

if [ $VERBOSE_INFO -gt 0 ]
then
	echo -e $INFO'Running Elasticsearch server'$WHITE
fi

############
# PHP Nginx
############

cd $WORKING_DIR/php-nginx

# Build php nginx container
docker build -t $REPOSITORY/nginx:0.1 .

# Run php-nginx container
cd $WORKING_DIR

PROJECT_DIR=`pwd`/applications/$APP_NAME
APP_DIR=$PROJECT_DIR/app
chmod go+wx $APP_DIR/logs
chmod go+wx $APP_DIR/cache

docker run -t -i -p 80:80 \
--name php-nginx-server \
--link elasticsearch-server:symfony__elasticsearch_ \
-v $PROJECT_DIR:/var/www/$APP_NAME \
-v `pwd`/php-nginx/conf/etc/nginx/sites-enabled:/etc/nginx/sites-enabled \
-v `pwd`/php-nginx/conf:/conf \
$REPOSITORY/nginx:0.1 || exit $?
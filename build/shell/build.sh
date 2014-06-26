#!/bin/bash

COLOR_PREFIX='\033'

RED=$COLOR_PREFIX'[31m'
BLUE=$COLOR_PREFIX'[36m'
BLACK=$COLOR_PREFIX'[0m'

INFO=$BLUE'[INFO] '
ERROR=$RED'[ERROR] '

############
# Copy resources to user home directory in order to avoid issues related to
# docker volumes mounted atop shared folders
############

HOME_DIR=~
WORKING_DIR=$HOME_DIR/package-app
DOCK=$WORKING_DIR/dockerfiles
OWNER=afup

# Stop containers but toran container before removing them
for CONTAINER_ID in `docker ps -a | grep "$OWNER\|squid" | awk '{print $1}'`; do
    docker stop $CONTAINER_ID && docker rm $CONTAINER_ID &&
        echo -e $INFO'Container of id '$CONTAINER_ID' has been stopped and removed.'$BLACK || \
        echo -e $INFO'Container of id '$CONTAINER_ID' could not be stopped or removed.'$BLACK
done;

if [ ! -d $WORKING_DIR ];
then
    create_working_dir='mkdir '$WORKING_DIR
    `$create_working_dir` &&
        echo -e $INFO'Working directory has been created in home directory of current user.'$BLACK || \
        echo -e $ERROR'Working directory could not be created in home directory of current user.'$BLACK
fi

if [ ! -d $WORKING_DIR/build ];
then
    copy_build_dir='cp -R ../../build '$WORKING_DIR'/build'
    echo -e $INFO'Executing "'$copy_build_dir'"'$BLACK
    `$copy_build_dir` && \
        echo -e $INFO'Build directory has been copied to working directory.'$BLACK || \
        echo -e $ERROR'Build directory could not be copied to working directory.'$BLACK
fi


if [ ! -d $WORKING_DIR/applications ];
then
    mkdir $WORKING_DIR/applications &&
        echo -e $INFO'Applications directory has been created in working directory.'$BLACK || \
        echo -e $ERROR'Applications directory could not be created in working directory.'$BLACK
fi

if [ ! -d $DOCK ];
then
    cp -R ../../dockerfiles $DOCK && \
        echo -e $INFO'Dockerfiles have been copied to working directory.'$BLACK || \
        echo -e $ERROR'Dockerfiles could not be copied to working directory.'$BLACK
fi

############
# Elasticsearch
############

if [ ! -d $DOCK/elasticsearch/var/lib/elasticsearch ]
then
	mkdir -p $DOCK/elasticsearch/var/lib/elasticsearch
fi

# Clean up
rm -r $DOCK/elasticsearch/var/lib/elasticsearch/* -f

# Set write permissions
find $DOCK/elasticsearch/var/lib/elasticsearch -not -path . -exec chmod og+w {} \;
find $DOCK/elasticsearch/var/lib/elasticsearch -not -path . -exec chown `whoami` {} \;

# Build Elasticsearch data volume image
cd $DOCK/data;
docker build -t $OWNER/elasticsearch-data-volume:0.1 .

# Build Elasticsearch image
cd $DOCK/elasticsearch;
docker build -t $OWNER/elasticsearch:0.1 .

# Run Elasticsearch data volume container
cd $DOCK
docker run -d --name elasticsearch-data-volume \
-p :22 \
-v `pwd`/elasticsearch/var/lib/elasticsearch:/var/lib/elasticsearch \
$OWNER/elasticsearch-data-volume:0.1

# Run Elasticsearch container in detached mode
cd $DOCK/
docker run -d -p :9200 \
--name elasticsearch-server \
--volumes-from elasticsearch-data-volume \
-v `pwd`/elasticsearch/var/lib/elasticsearch:/var/lib/elasticsearch \
$OWNER/elasticsearch:0.1 && \
    echo -e $INFO'Running Elasticsearch server'$BLACK || exit $?

############
# PHP FPM - nginx
############

#cd $DOCK/php-fpm-nginx
#
## Build PHP FPM and nginx image
#docker build -t $OWNER/php-fpm-nginx:0.1 .
#
#docker push php-fpm-nginx:0.1

############
# Symfony standard edition
############

CONTAINER_NAME=symfony-standard
IMAGE_NAME=$CONTAINER_NAME
cd $DOCK/$CONTAINER_NAME

# Build Symfony standard edition image
build_symfony_standard='docker build -t '$OWNER'/'$IMAGE_NAME':0.1 .'
echo -e $INFO'Executing "'$build_symfony_standard'" from "'`pwd`'"'$BLACK
`$build_symfony_standard`

cd $DOCK

# Symfony standard project will be created at runtime if none has been created yet
APP_NAME='symfony-standard'
WEB_DIR=`pwd`/../applications
APP_DIR=$WEB_DIR/app

if [ -d $APP_DIR/logs ];
then
    # Set logs permissions
    chmod go+wx $APP_DIR/logs
fi

if [ -d $APP_DIR/cache ];
then
    # Set cache permissions
    chmod go+wx $APP_DIR/cache
fi

if [ -d $WEB_DIR/composer ];
then
    mkdir $WEB_DIR/composer
fi

# Run php-nginx container
docker run -t -i -p 80:80 \
--name $CONTAINER_NAME \
--link elasticsearch-server:symfony__elasticsearch_ \
-v $WEB_DIR:/var/www \
-v ~/composer:/.composer \
-v `pwd`/$IMAGE_NAME/conf/etc/nginx/sites-enabled:/etc/nginx/sites-enabled \
-v `pwd`/$IMAGE_NAME//conf:/conf \
$OWNER/$IMAGE_NAME:0.1 || exit $?

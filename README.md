# Package a Symfony2 application using Docker

This repository was created to host some of the resources referred to in the following slideshow

[Développer et packager votre application Symfony2 avec Docker et Vagrant](https://speakerdeck.com/thierrymarianne/developper-et-packager-une-application-symfony2-avec-docker)

## Installation

    git clone https://github.com:thierrymarianne/symfony2-docker-vagrant.git

## Build and run containers using shell script

### For Linux users

Follow installation instructions for your distribution

[https://docs.docker.com/installation](https://docs.docker.com/installation)

Run the build shell script from wherever this project has been cloned

    # You need to be a privileged user in order to execute docker command
    sudo /bin/bash -c 'cd ./build/shell && source build.sh'

### For MacOSX / Windows users

Install Vagrant by following instructions

[https://www.vagrantup.com/downloads.html](https://www.vagrantup.com/downloads.html)

Install VirtualBox by downloading its latest release available for your operating system

[http://www.oracle.com/technetwork/server-storage/virtualbox/downloads/index.html?ssSourceSiteId=otnjp](http://www.oracle.com/technetwork/server-storage/virtualbox/downloads/index.html?ssSourceSiteId=otnjp)

Install Docker by provisioning a vagrant box using shell and puppet

    # Download a vagrant box and install Docker (plus some development tools)
    vagrant up

    # Access the vagrant box
    vagrant ssh

Run the shell script as a privileged user (having permissions to access docker socket)

    sudo /bin/bash -c 'cd /vagrant/build/shell && source build.sh'

### Testing your application and services are running

    # Testing availability of Elasticsearch
    curl -XGET 'http://'$SYMFONY__ELASTICSEARCH__PORT_9200_TCP_ADDR':9200

    # Testing availability of Not Found page served by Symfony standard edition via nginx / php-fpm
    curl -XGET http://127.0.0.1

## TODO

Run the following containers using fig
 * Elastisearch data volume,
 * Elastisearch,
 * Symfony standard edition

### Run containers using fig

    # /!\ fig relies on existing images so shell build shall be executed first)
    cd build/fig && fig up

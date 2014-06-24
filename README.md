# Package Symfony2 application using Docker

Please read the slides (which actually works :)

/!\ The provided configuration files is a work in progress which aims at exposing
 * an instance of Elasticsearch
 * a Symfony2 application depending on Elasticsearch

## Requirements

Install docker

## Build and run containers using shell

git clone https://github.com:thierrymarianne/symfony2-docker-vagrant.git

    $(cd build/shell) && . build.sh

## Run containers using fig

    # /!\ fig relies on existing images so shell build shall be executed first)
    cd build/fig && fig up

## TODO

Add example exposing working Acme application based on Symfony2 Standard Edition

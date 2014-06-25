FROM ubuntu:14.04

MAINTAINER Thierry Marianne

# Disable user prompts
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update

# Setup repositories
RUN apt-get install -y --force-yes software-properties-common

# If host is running squid-deb-proxy on port 8000, populate /etc/apt/apt.conf.d/30proxy
# By default, squid-deb-proxy 403s unknown sources, so apt shouldn't proxy ppa.launchpad.net
# Requires installation of squid-deb-proxy on host by executing next command
# sudo apt-get install squid-deb-proxy avahi-utils --force-yes -y
RUN route -n | awk '/^0.0.0.0/ {print $2}' > /tmp/host_ip.txt
RUN echo "HEAD /" | nc `cat /tmp/host_ip.txt` 8000 | grep squid-deb-proxy \
  && (echo "Acquire::http::Proxy \"http://$(cat /tmp/host_ip.txt):8000\";" > /etc/apt/apt.conf.d/30proxy) \
  && (echo "Acquire::http::Proxy::ppa.launchpad.net DIRECT;" >> /etc/apt/apt.conf.d/30proxy) \
  || echo "No squid-deb-proxy detected on docker host"

RUN add-apt-repository -y ppa:nginx/stable
RUN echo 'deb http://ppa.launchpad.net/ondrej/php5/ubuntu trusty main' >> /etc/apt/sources.list
RUN echo 'deb-src http://ppa.launchpad.net/ondrej/php5/ubuntu trusty main' >> /etc/apt/sources.list

RUN add-apt-repository -y ppa:ondrej/php5

RUN apt-get update

# Install requirement for synchronization with time server
RUN apt-get install -y --force-yes ntpdate
RUN cp /usr/share/zoneinfo/Europe/Paris /etc/localtime

# Declare timezone
RUN echo "TZ='Europe/Paris'; export TZ" >> ~/.profile

# Install nginx
RUN apt-get install -y --force-yes nginx

# Configure nginx to run it in non-daemonized mode
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf

# Import script used to launch PHP FPM and nginx
ADD ./php-nginx /etc/init.d/php-nginx

RUN chmod +x /etc/init.d/php-nginx
RUN update-rc.d php-nginx defaults

# Install PHP and its extensions
RUN apt-get install -y --force-yes php5-fpm php5-cli \
    php5-dev php-pear php5-mysql php5-json php5-mcrypt php5-gd php5-sqlite php5-curl \
    php5-intl php5-imagick php5-redis php5-apcu

##### START ##### build / testing requirements

# Install git
RUN apt-get install -y git

# Install PHP xdebug extension
RUN apt-get install -y --force-yes php5-xdebug

# Increase xdebug max nesting level
RUN echo "xdebug.max_nesting_level = 400" >> /etc/php5/cli/php.ini
RUN echo "xdebug.max_nesting_level = 400" >> /etc/php5/fpm/php.ini

##### END ##### build / testing requirements

# Expose ports
EXPOSE 80

CMD /bin/bash -c 'service php-nginx start'

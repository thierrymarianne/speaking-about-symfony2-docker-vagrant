FROM afup/php-fpm-nginx:0.1

MAINTAINER Thierry Marianne

# Install text editor
RUN apt-get install vim -y --force-yes

ADD create-symfony-project.sh /tmp/create-symfony-project.sh

# Expose ports
EXPOSE 80

CMD /bin/bash -c '. /tmp/create-symfony-project.sh && service php-nginx start & /bin/bash'

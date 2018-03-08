FROM debian:jessie
MAINTAINER Lukasz Burylo <lukasz@burylo.com>


RUN apt-get update && \
    apt-get install -y --force-yes --no-install-recommends ca-certificates wget &&\
    wget https://www.dotdeb.org/dotdeb.gpg &&\
    apt-key add dotdeb.gpg

RUN echo "deb http://packages.dotdeb.org jessie all\n" > /etc/apt/sources.list.d/php.list && \
    echo "deb-src http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list.d/php.list

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --force-yes --no-install-recommends apache2 php7.0 php7.0-mysql php7.0-xml php7.0-gd php7.0-mbstring php7.0-curl git-core

ENV APACHE_CONFDIR /etc/apache2
ENV APACHE_ENVVARS $APACHE_CONFDIR/envvars
RUN set -ex \
    && . "$APACHE_ENVVARS" \
    && ln -sfT /dev/stderr "$APACHE_LOG_DIR/error.log" \
    && ln -sfT /dev/stdout "$APACHE_LOG_DIR/access.log" \
    && ln -sfT /dev/stdout "$APACHE_LOG_DIR/other_vhosts_access.log"

RUN a2enmod rewrite
RUN cp /usr/share/zoneinfo/Europe/Warsaw /etc/localtime

EXPOSE 80

COPY 000-default.conf /etc/apache2/sites-available/
COPY apache2-foreground /usr/local/bin/
WORKDIR /var/www/html
CMD ["apache2-foreground"]

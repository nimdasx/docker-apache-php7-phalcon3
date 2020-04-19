FROM php:7.2-apache

LABEL maintainer="nimdasx@gmail.com"
LABEL description="Apache PHP 7.2 Phalcon 3.4.5"

#set timezone
RUN ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

#install unzip
RUN apt-get -y update \
&& apt-get install -y \
unzip \
libpng-dev \
&& rm -rf /var/lib/apt/lists/*

#install phalcon
COPY cphalcon-3.4.5.zip /usr/local/src/
WORKDIR /usr/local/src
RUN unzip cphalcon-3.4.5.zip
WORKDIR /usr/local/src/cphalcon-3.4.5/build
RUN ./install
WORKDIR /
RUN rm -rf /usr/local/src/*
#enable phalcon
RUN docker-php-ext-enable phalcon

RUN docker-php-ext-install pdo_mysql gd

# config php
COPY php-nimdasx.ini /usr/local/etc/php/conf.d/php-nimdasx.ini

# apache
RUN a2enmod rewrite
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/-Indexes/+Indexes/' /etc/apache2/conf-enabled/docker-php.conf
FROM php:7.2-apache

LABEL maintainer="nimdasx@gmail.com"
LABEL description="Apache PHP 7.2 Phalcon 3.4.5"

#set timezone
RUN ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

#install unzip
RUN apt update
RUN apt install -y unzip
RUN apt-get clean
#RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

#install phalcon
COPY cphalcon-3.4.5.zip /usr/local/src/
WORKDIR /usr/local/src
RUN unzip cphalcon-3.4.5.zip
WORKDIR /usr/local/src/cphalcon-3.4.5/build
#RUN git clone https://github.com/phalcon/cphalcon.git --branch v3.4.5 --single-branch --depth=1
#RUN wget https://github.com/phalcon/cphalcon/archive/v3.4.5.zip
#WORKDIR /usr/local/src/cphalcon/build
RUN ./install
WORKDIR /
RUN rm -rf /usr/local/src/*
#enable phalcon
RUN docker-php-ext-enable phalcon

#custom config php
COPY php-nimdasx.ini /usr/local/etc/php/conf.d/php-nimdasx.ini

#pdo_mysql
RUN docker-php-ext-install pdo_mysql

# konfigurasi apache
## aktifkan rewrite
RUN a2enmod rewrite
## aktifkan indexes
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/-Indexes/+Indexes/' /etc/apache2/conf-enabled/docker-php.conf

#gd
RUN apt install -y libpng-dev
RUN docker-php-ext-install gd

#clean up
RUN apt-get clean
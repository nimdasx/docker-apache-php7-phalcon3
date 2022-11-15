FROM php:7.3-apache-buster

LABEL maintainer="nimdasx@gmail.com"
LABEL description="Apache PHP 7.3 Phalcon3"

#set timezone
RUN ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

#config php
COPY php-nimdasx.ini /usr/local/etc/php/conf.d/php-nimdasx.ini

#apache
RUN a2enmod rewrite \
    && sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/-Indexes/+Indexes/' /etc/apache2/conf-enabled/docker-php.conf

#dependensi
RUN apt-get -y update \
    && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libzip-dev \
    unzip \
    libpng-dev \
    libpq-dev \
    gnupg \
    gnupg2 \
    gnupg1 \
    git

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install zip mysqli pdo_mysql pdo_pgsql gd \
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

#redis
RUN pecl install -o -f redis \
&&  rm -rf /tmp/pear \
&&  docker-php-ext-enable redis

#sqlsrv
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
   && curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
   && apt-get update \
   && ACCEPT_EULA=Y apt-get install -y \
   msodbcsql17 \
   mssql-tools \
   unixodbc-dev \
   libgssapi-krb5-2 \
   && rm -rf /var/lib/apt/lists/* \
   && pecl install sqlsrv pdo_sqlsrv \
   && docker-php-ext-enable sqlsrv pdo_sqlsrv \
   && sed -i 's/TLSv1.2/TLSv1.0/g' /etc/ssl/openssl.cnf

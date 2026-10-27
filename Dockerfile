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
# Use archive.debian.org for old buster repos
RUN sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list && \
    sed -i 's|http://security.debian.org/debian-security|http://archive.debian.org/debian-security|g' /etc/apt/sources.list && \
    apt-get -y update -o Acquire::Check-Valid-Until=false \
    && apt-get install -y \
    patch \
    apache2-dev \
    libargon2-dev \
    libcurl4-openssl-dev \
    libreadline-dev \
    libsodium-dev \
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev \
    zlib1g-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libzip-dev \
    unzip \
    libpng-dev \
    libpq-dev \
    gnupg \
    gnupg2 \
    gnupg1 \
    git \
    libbz2-dev \
    libgmp-dev

# Recompile PHP 7.3 with CVE-2026-109618 and CVE-2026-109619 security patch
COPY patches/php-7.3-CVE-2026-109618-109619.patch /tmp/
RUN set -eux; \
    docker-php-source extract; \
    cd /usr/src/php; \
    patch -p1 < /tmp/php-7.3-CVE-2026-109618-109619.patch; \
    gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
    debMultiarch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)"; \
    if [ ! -d /usr/include/curl ]; then \
        ln -sfT "/usr/include/$debMultiarch/curl" /usr/local/include/curl; \
    fi; \
    ./configure \
        --build="$gnuArch" \
        --with-config-file-path="$PHP_INI_DIR" \
        --with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
        --enable-option-checking=fatal \
        --with-mhash \
        --with-pic \
        --enable-ftp \
        --enable-mbstring \
        --enable-mysqlnd \
        --with-password-argon2 \
        --with-sodium=shared \
        --with-pdo-sqlite=/usr \
        --with-sqlite3=/usr \
        --with-curl \
        --with-iconv \
        --with-openssl \
        --with-readline \
        --with-zlib \
        --disable-phpdbg \
        --with-libdir="lib/$debMultiarch" \
        --disable-cgi \
        --with-apxs2 \
    ; \
    make -j "$(nproc)"; \
    find -type f -name '*.a' -delete; \
    make install; \
    make clean; \
    cd /; \
    docker-php-source delete; \
    rm -f /tmp/php-7.3-CVE-2026-109618-109619.patch

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install zip mysqli pdo_mysql pdo_pgsql gd bcmath \
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

#sqlsrv... still not working
RUN ARCH=`uname -m` && \
    if [ "$ARCH" == "x86_64" ]; then \
        curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
        curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
        apt-get update && \
        ACCEPT_EULA=Y apt-get install -y \
            msodbcsql17 \
            mssql-tools \
            unixodbc-dev \
            libgssapi-krb5-2 && \
        rm -rf /var/lib/apt/lists/* && \
        pecl install sqlsrv pdo_sqlsrv && \
        docker-php-ext-enable sqlsrv pdo_sqlsrv && \
        sed -i 's/TLSv1.2/TLSv1.0/g' /etc/ssl/openssl.cnf; \
   fi

#a2enmod remoteip
RUN a2enmod remoteip

COPY 000-default.conf /etc/apache2/sites-enabled/000-default.conf

#sqlsrv, khsus x86_64
#RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
#    && curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
#    && apt-get update \
#    && ACCEPT_EULA=Y apt-get install -y \
#         msodbcsql17 \
#         mssql-tools \
#         unixodbc-dev \
#         libgssapi-krb5-2 \
#    && rm -rf /var/lib/apt/lists/* \
#    && pecl install sqlsrv pdo_sqlsrv \
#    && docker-php-ext-enable sqlsrv pdo_sqlsrv \
#    && sed -i 's/TLSv1.2/TLSv1.0/g' /etc/ssl/openssl.cnf
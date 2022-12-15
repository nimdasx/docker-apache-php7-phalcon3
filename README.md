# docker apache php-7.3 phalcon-3.4
## catatan
````
docker run -d -p 81:80 -v /Users/sofyan/Dev/php:/var/www/html --name dinosaurus nimdasx/apache-php7-phalcon3
docker buildx create --name jangkrik --use --bootstrap
````
## build dan push ke github
````
docker buildx build --push --platform linux/amd64,linux/arm64 --tag ghcr.io/nimdasx/apache-php7-phalcon3 .
````
## build dan push ke docker hub
````
docker buildx build --push --platform linux/amd64,linux/arm64 --tag nimdasx/apache-php7-phalcon3 .
````
## build dan push ke docker hub sik x86_64, uncomment sik bagian sqlsrv ng Dockerfile
````
docker build --tag nimdasx/apache-php7-phalcon3:sqlsrv .
docker push nimdasx/apache-php7-phalcon3:sqlsrv
````
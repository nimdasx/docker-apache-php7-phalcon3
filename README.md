# Catatan
````
docker build --tag nimdasx/sf-phalcon-3 .   
docker run -d -p 81:80 -v /Users/sofyan/Dev/php:/var/www/html --name terserah nimdasx/sf-phalcon-3  
docker rm -f terserah  
docker push nimdasx/sf-phalcon-3  
````

# Upgrade your composer with
docker-compose run --rm -w /var/www/html web php composer.phar update
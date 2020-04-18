# phalcon 3 php apache
from php:7.2-apache yang mana basisnya adalah debian 10 buster
## contoh cara run kalau pakai docker-compose
silahkan edit `docker-compose.yml` sesuai kebutuhan 
teruatama bagian volumes  
kalo udah jalankan pakai perintah :  
`docker-compose up -d`  
kalau mau mematikan  
`docker-compose down`
## contoh cara run langsung (tidak pakai docker-compose)
jalankan  
`docker run -d -p 80:80 -v d:/dev/php:/var/www/html --name terserah nimdasx/sf-phalcon-3` \
matikan  
`docker rm -f terserah`
## catatan pribadi / abaikan saja
`docker build --tag nimdasx/sf-phalcon-3 .` \
`docker push nimdasx/sf-phalcon-3`
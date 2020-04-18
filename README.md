# phalcon 3 php apache
from php:7.2-apache yang mana basisnya adalah debian 10 buster
## contoh cara run kalau pakai docker-compose
silahkan edit docker-compose.yml sesuai kebutuhan \
kalo udah jalankan pakai perintah : \
docker-compose up -d
## catatan pribadi (abaikan saja wkwkwk)
docker build --tag nimdasx/sf-phalcon-3 . \
docker push nimdasx/sf-phalcon-3
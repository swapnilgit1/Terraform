#! /bin/bash

sudo -i
sudo apt-get update
sudo apt-get install nginx -y
echo "hi,  swapnil" > /var/www/html/index.nginx-debian.html
service nginx restart

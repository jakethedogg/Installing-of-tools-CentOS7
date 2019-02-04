#!/bin/bash

for ipaddress in $(cat ip-address.txt)
do

echo "Enter root password for host $ipaddress  : "
read -s password

sshpass -p $password ssh -o StrictHostKeyChecking=no root@$ipaddress<<EOF


#Installing Nginx
yum install -y epel-release yum-utils
yum install -y nginx
systemctl enable nginx
systemctl start nginx
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --reload

#Installing Redis

yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum-config-manager --enable remi
yum install -y redis
systemctl start redis
systemctl enable redis

#Instaling MySQL 5.6

yum localinstall -y http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm
yum remove -y mariadb-libs
yum autoremove -y
yum install -y mysql-community-server
systemctl enable mysqld
systemctl start mysqld

#Installing PHP 7.1


yum-config-manager --enable remi-php71
yum install -y php php-common php-opcache php-mcrypt php-cli php-gd php-curl php-mysql
yum install -y php-fpm
yum install -y php-bcmath
yum install -y php-amqp
yum install -y php-pdo
yum install -y gcc php-devel php-pear
yum install -y ImageMagick ImageMagick-devel
pecl install imagick<<<"\n"
echo extension=imagick.so >> /etc/php.ini

chown -R root:nginx /var/lib/php
systemctl start php-fpm
systemctl enable php-fpm
systemctl restart nginx


yum install -y phpmyadmin
ln -s /usr/share/phpMyAdmin /usr/share/nginx/html
systemctl restart php-fpm
systemctl restart nginx

EOF





done

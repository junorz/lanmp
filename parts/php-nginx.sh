#!/bin/bash
#====================================================================
# PHP with Nginx Auto Install Script
#
# Copyright (c) 2011-2015 Junorz.com All rights reserved.
# 
# Intro: http://www.junorz.com/archives/374.html
#
#====================================================================


# 检查是否为管理员
if [ $(id -u) != "0" ]; then
    echo "Please login as root to run this script"
    exit 1
fi

#下载编译
cd /root
wget -O php.tar.gz http://sourceforge.net/projects/lanmp/files/php-5.6.6.tar.gz/download
tar -zxf php.tar.gz
cd php*
./configure --prefix=/usr/local/php \
--with-config-file-path=/usr/local/php/etc \
--enable-fpm \
--with-fpm-user=www \
--with-fpm-group=www \
--with-mysql=/usr/local/mysql \
--with-mysqli=/usr/local/mysql/bin/mysql_config \
--with-pdo-mysql=/usr/local/mysql \
--with-iconv-dir \
--with-freetype-dir \
--with-jpeg-dir \
--with-png-dir \
--with-zlib \
--with-libxml-dir \
--enable-xml \
--disable-rpath \
--enable-bcmath \
--enable-shmop \
--enable-sysvsem \
--enable-inline-optimization \
--with-curl \
--enable-mbregex \
--enable-mbstring \
--with-mcrypt \
--enable-ftp \
--with-gd \
--enable-gd-native-ttf \
--with-openssl \
--with-mhash \
--enable-pcntl \
--enable-sockets \
--with-xmlrpc \
--enable-zip \
--enable-soap \
--with-gettext
make && make install

#复制配置文件
cp php.ini-development /usr/local/php/etc/php.ini
cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
cp sapi/fpm/php-fpm /usr/local/bin

#软链接以便命令行直接调用
ln -s /usr/local/bin/php-fpm /usr/bin/php-fpm

#启动php-fpm请直接在命令行输入php
#停止php-fpm请直接在命令行输入pkill php

#加入开机自启动，如果不需要自在/etc/rc.d/rc.local文件里删除相应命令
echo "/usr/bin/php-fpm" >> /etc/rc.d/rc.local

#配置php.ini文件
sed -i "s/^.*cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/g" /usr/local/php/etc/php.ini
sed -i "s/;date.timezone =/date.timezone = Asia\/Shanghai/g" /usr/local/php/etc/php.ini
sed -i "s/post_max_size =.*/post_max_size = 50M/g" /usr/local/php/etc/php.ini
sed -i "s/upload_max_filesize =.*/upload_max_filesize = 50M/g" /usr/local/php/etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /usr/local/php/etc/php.ini

#替换Nginx.conf文件以便支持PHP文件
mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx-backup.conf
wget -O /usr/local/nginx/conf/nginx.conf http://source.ocha.so/nginx.conf

#重启nginx
/usr/bin/nginx -s reload

#启动php-fpm进程
/usr/bin/php-fpm

#下载探针
wget -O /usr/local/nginx/html/tz.zip http://www.yahei.net/tz/tz.zip
cd /usr/local/nginx/html/
unzip tz.zip
rm -rf /usr/local/nginx/html/tz.zip

#下载phpMyAdmin
wget -O /usr/local/nginx/html/phpmyadmin.tar.gz http://sourceforge.net/projects/phpmyadmin/files/phpMyAdmin/4.3.12/phpMyAdmin-4.3.12-all-languages.tar.gz/download
tar -zxf /usr/local/nginx/html/phpmyadmin.tar.gz -C /usr/local/nginx/html/
mv /usr/local/nginx/html/phpMyAdmin-* /usr/local/nginx/html/phpmyadmin
rm -rf /usr/local/nginx/html/phpmyadmin.tar.gz


echo "================================================"
echo "脚本已运行完成 Script Written by Junorz.com"
echo "访问http://您的网址/tz.php可以访问PHP探针"
echo "访问http://您的网址/phpmyadmin可以访问phpmyadmin"
echo "================================================"

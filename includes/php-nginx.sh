#!/bin/bash
#====================================================================
# PHP with Nginx Auto Install Script
#
# Copyright (c) 2011-2015 Junorz.com All rights reserved.
#
# Intro: http://www.junorz.com/archives/374.html
#
#====================================================================

Install_PHPwithNginx(){

#下载编译
cd ~/.lanmp/resources

#判断是否已经存在源文件
if [ ! -f ~/.lanmp/resources/php.tar.gz ]; then
	wget -O php.tar.gz http://php.net/get/php-5.6.15.tar.gz/from/this/mirror
fi

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
cp sapi/fpm/php-fpm /usr/bin


#启动php-fpm请直接在命令行输入php
#停止php-fpm请直接在命令行输入pkill php

#加入开机自启动
cp ~/.lanmp/includes/init.phpfpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm
if [ "$PM" = "yum" ]; then
    chkconfig --add php-fpm
    chkconfig php-fpm on
elif [ "$PM" = "apt" ]; then
    update-rc.d -f php-fpm defaults
fi

#配置php.ini文件
sed -i "s/^.*cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/g" /usr/local/php/etc/php.ini
sed -i "s/;date.timezone =/date.timezone = Asia\/Shanghai/g" /usr/local/php/etc/php.ini
sed -i "s/post_max_size =.*/post_max_size = 50M/g" /usr/local/php/etc/php.ini
sed -i "s/upload_max_filesize =.*/upload_max_filesize = 50M/g" /usr/local/php/etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /usr/local/php/etc/php.ini

#替换Nginx.conf文件以便支持PHP文件
mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx_backup.conf
cp ~/.lanmp/parts/nginx.conf /usr/local/nginx/conf/nginx.conf

#重启nginx
/usr/bin/nginx -s reload

#启动php-fpm进程
service php-fpm start

#下载探针
wget -O /usr/local/nginx/html/tz.zip http://www.yahei.net/tz/tz.zip
cd /usr/local/nginx/html/
unzip tz.zip
rm -rf /usr/local/nginx/html/tz.zip

#下载phpMyAdmin
wget -O /usr/local/nginx/html/phpmyadmin.tar.gz https://files.phpmyadmin.net/phpMyAdmin/4.5.2/phpMyAdmin-4.5.2-all-languages.tar.gz
tar -zxf /usr/local/nginx/html/phpmyadmin.tar.gz -C /usr/local/nginx/html/
mv /usr/local/nginx/html/phpMyAdmin-* /usr/local/nginx/html/phpmyadmin
rm -rf /usr/local/nginx/html/phpmyadmin.tar.gz

}

#!/bin/bash
#====================================================================
# PHP with Apache Auto Install Script
#
# Copyright (c) 2011-2015 Junorz.com All rights reserved.
#
# Intro: http://www.junorz.com/archives/374.html
#
#====================================================================

Install_PHPwithApache(){
#下载编译
cd ~/.lanmp/resources
#判断是否已经存在源文件
if [ ! -f ~/.lanmp/resources/php.tar.gz ]; then
  wget -O php.tar.gz http://php.net/get/php-7.0.3.tar.gz/from/this/mirror
fi
tar -zxf php.tar.gz
cd php*
./configure --prefix=/usr/local/php \
--with-config-file-path=/usr/local/php/etc \
--enable-fpm \
--with-fpm-user=www \
--with-fpm-group=www \
--with-apxs2=/usr/local/apache/bin/apxs \
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

#配置httpd.conf文件
cat >> /usr/local/apache/conf/httpd.conf <<EOF
<FilesMatch \.php$>
    SetHandler application/x-httpd-php
</FilesMatch>
EOF
sed -i "s/.*DirectoryIndex index.html/  DirectoryIndex index.php index.html/g" /usr/local/apache/conf/httpd.conf

#配置php.ini文件
sed -i "s/;date.timezone =/date.timezone = Asia\/Shanghai/g" /usr/local/php/etc/php.ini
sed -i "s/post_max_size =.*/post_max_size = 50M/g" /usr/local/php/etc/php.ini
sed -i "s/upload_max_filesize =.*/upload_max_filesize = 50M/g" /usr/local/php/etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /usr/local/php/etc/php.ini

#重启服务器
service httpd restart

#下载探针
#目前PHP7没有好的探针，先保留
#wget -O /usr/local/apache/htdocs/tz.zip http://www.yahei.net/tz/tz.zip
#cd /usr/local/apache/htdocs/
#unzip tz.zip
#rm -rf /usr/local/apache/htdocs/tz.zip

#下载phpMyAdmin
wget -O /usr/local/apache/htdocs/phpmyadmin.tar.gz https://files.phpmyadmin.net/phpMyAdmin/4.5.2/phpMyAdmin-4.5.2-all-languages.tar.gz
tar -zxf /usr/local/apache/htdocs/phpmyadmin.tar.gz -C /usr/local/apache/htdocs/
mv /usr/local/apache/htdocs/phpMyAdmin-* /usr/local/apache/htdocs/phpmyadmin
rm -rf /usr/local/apache/htdocs/phpmyadmin.tar.gz
}

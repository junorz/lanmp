#!/bin/bash
#====================================================================
# PHP with Apache Auto Install Script
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

#安装前删除resources文件夹下的源文件
read -p "PHP resource files in ~/.lanmp/resources must be deleted before installation, press Enter to continue or Ctrl+C to quit this script."
rm -rf ~/.lanmp/resources/php*


#下载编译
cd ~/.lanmp/resources
wget -O php.tar.gz http://php.net/get/php-5.6.15.tar.gz/from/this/mirror
tar -zxf php.tar.gz
cd php*
./configure --prefix=/usr/local/php \
--with-config-file-path=/usr/local/php/etc \
--enable-fpm \
--with-fpm-user=www \
--with-fpm-group=www \
--with-apxs2=/usr/local/apache/bin/apxs \
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
wget -O /usr/local/apache/htdocs/tz.zip http://www.yahei.net/tz/tz.zip
cd /usr/local/apache/htdocs/
unzip tz.zip
rm -rf /usr/local/apache/htdocs/tz.zip

#下载phpMyAdmin
wget -O /usr/local/apache/htdocs/phpmyadmin.tar.gz https://files.phpmyadmin.net/phpMyAdmin/4.5.2/phpMyAdmin-4.5.2-all-languages.tar.gz
tar -zxf /usr/local/apache/htdocs/phpmyadmin.tar.gz -C /usr/local/apache/htdocs/
mv /usr/local/apache/htdocs/phpMyAdmin-* /usr/local/apache/htdocs/phpmyadmin
rm -rf /usr/local/apache/htdocs/phpmyadmin.tar.gz

#询问是否删除源文件
read -p "Would you like to delete resource files downloaded in ~/.lanmp/resources?[Y/N]" afterdel
if [ "$afterdel" = "Y" ] || [ "$afterdel" = "y" ]; then
    rm -rf ~/.lanmp/resources/php*
    echo "Resources files deleted."
else
    echo "Installation finished without delete resource files."
fi


echo "================================================"
echo "脚本已运行完成 Script Written by Junorz.com"
echo "访问http://您的网址/tz.php可以访问PHP探针"
echo "访问http://您的网址/phpmyadmin可以访问phpmyadmin"
echo "================================================"

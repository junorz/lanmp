#!/bin/bash
#Welcome http://www.junorz.com


# 检查是否为管理员
if [ $(id -u) != "0" ]; then
    echo "Please login as root to run this script"
    exit 1
fi

#下载编译
cd /root
wget http://source.ocha.so/php.tar.gz
tar -zxf php*.tar.gz
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
--without-pear \
--with-gettext
make && make install

#复制配置文件
cp php.ini-development /usr/local/php/etc/php.ini
cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
cp sapi/fpm/php-fpm /usr/local/bin

#软链接以便命令行直接调用
ln -s /usr/local/bin/php-fpm /usr/bin/php

#启动php-fpm请直接在命令行输入php
#停止php-fpm请直接在命令行输入pkill php

#加入开机自启动，如果不需要自在/etc/rc.d/rc.local文件里删除相应命令
echo "/usr/bin/php" >> /etc/rc.d/rc.local

#配置php.ini文件
sed -i "s/^.*cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/g" /usr/local/php/etc/php.ini
sed -i "s/;date.timezone =/date.timezone = Asia\/Shanghai/g" /usr/local/php/etc/php.ini
sed -i "s/post_max_size =.*/post_max_size = 50M/g" /usr/local/php/etc/php.ini
sed -i "s/upload_max_filesize =.*/upload_max_filesize = 50M/g" /usr/local/php/etc/php.ini

#替换Nginx.conf文件以便支持PHP文件
mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx-backup.conf
wget -O /usr/local/nginx/conf/nginx.conf http://source.ocha.so/nginx.conf

#重启nginx
/usr/bin/nginx -s reload

#启动php-fpm进程
/usr/bin/php

#下载探针
wget -O /usr/local/nginx/html/tz.zip http://www.yahei.net/tz/tz.zip
cd /usr/local/nginx/html/
unzip tz.zip
rm -rf /usr/local/nginx/html/tz.zip

#下载phpMyAdmin
wget -O /usr/local/nginx/html/phpmyadmin.zip http://source.ocha.so/phpmyadmin.zip
cd /usr/local/nginx/html/
unzip phpmyadmin.zip
mv /usr/local/nginx/html/phpMyAdmin-* /usr/local/nginx/html/phpmyadmin
rm -rf /usr/local/nginx/html/phpmyadmin.zip

cd /root

echo "========================================================================="
echo "PHP With Nginx已安装完成，请运行其他安装脚本 Script Written by Junorz.com"
echo "访问http://您的网址/tz.php可以访问PHP探针"
echo "========================================================================="

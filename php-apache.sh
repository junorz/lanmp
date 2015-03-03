#!/bin/bash
#Welcome http://www.junorz.com


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
--without-pear \
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


#下载探针
wget -O /usr/local/apache/htdocs/tz.zip http://www.yahei.net/tz/tz.zip
cd /usr/local/apache/htdocs/
unzip tz.zip
rm -rf /usr/local/apache/htdocs/tz.zip

#下载phpMyAdmin
wget -O /usr/local/apache/htdocs/phpmyadmin.tar.gz http://sourceforge.net/projects/phpmyadmin/files/phpMyAdmin/4.3.11/phpMyAdmin-4.3.11-all-languages.tar.gz/download
tar -zxf /usr/local/nginx/html/phpmyadmin.tar.gz -C /usr/local/apache/htdocs/
mv /usr/local/apache/htdocs/phpMyAdmin-* /usr/local/apache/htdocs/phpmyadmin
rm -rf /usr/local/apache/htdocs/phpmyadmin.tar.gz

#重启服务器
service httpd restart

echo "========================================================================="
echo "PHP With Nginx已安装完成，请运行其他安装脚本 Script Written by Junorz.com"
echo "访问http://您的网址/tz.php可以访问PHP探针"
echo "访问http://您的网址/phpmyadmin可以访问phpmyadmin"
echo "========================================================================="

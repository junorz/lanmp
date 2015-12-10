#!/bin/bash
#====================================================================
# Apache Auto Install Script
#
# Copyright (c) 2011-2015 Junorz.com All rights reserved.
#
# Intro: http://www.junorz.com/archives/374.html
#
#====================================================================


Install_Apache(){
#创建运行Apache的用户
groupadd www
useradd -M -s /sbin/nologin -g www www

#下载编译
cd ~/.lanmp/resources

#判断是否已经存在源文件
if [ ! -f ~/.lanmp/resources/httpd.tar.gz ]; then
  wget -O httpd.tar.gz  http://sourceforge.net/projects/lanmp/files/httpd-2.4.17.tar.gz/download
fi

tar -zxf httpd.tar.gz
cd httpd*
./configure --prefix=/usr/local/apache \
--with-apr=/usr/local/apr/bin/apr-1-config \
--with-apr-util=/usr/local/apr-util/bin/apu-1-config \
--enable-so \
--enable-rewrite \
--enable-ssl \
--enable-mods-shared=all \
--enable-expires \
--with-mpm=prefork
make && make install

#配置httpd.conf文件
sed -i "s/User daemon/User www/g" /usr/local/apache/conf/httpd.conf
sed -i "s/Group daemon/Group www/g" /usr/local/apache/conf/httpd.conf
sed -i "s/#ServerName www.example.com:80/ServerName localhost/g" /usr/local/apache/conf/httpd.conf

#添加服务
cp ~/.lanmp/includes/init.httpd /etc/init.d/httpd
chmod +x /etc/init.d/httpd
if [ "$PM" = "yum" ]; then
    chkconfig --add httpd
    chkconfig httpd on
elif [ "$PM" = "apt" ]; then
    update-rc.d -f httpd defaults
fi
service httpd start

}

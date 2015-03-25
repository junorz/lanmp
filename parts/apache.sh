#!/bin/bash
#====================================================================
# Apache Auto Install Script
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
read -p "Apache resource files in ~/.lanmp/resources must be deleted before installation, press Enter to continue or Ctrl+C to quit this script."
rm -rf ~/.lanmp/resources/httpd*


#创建运行Apache的用户
groupadd www
useradd -s /sbin/nologin -g www www

#下载编译
cd ~/.lanmp/resources
wget -O httpd.tar.gz  http://sourceforge.net/projects/lanmp/files/httpd-2.4.12.tar.gz/download
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
sed -i "2 a #chkconfig:345 85 15" /usr/local/apache/bin/apachectl
sed -i "3 a #description:httpd" /usr/local/apache/bin/apachectl

#添加服务
cp /usr/local/apache/bin/apachectl /etc/init.d/httpd
chkconfig --add httpd
service httpd start

#询问是否删除源文件
read -p "Would you like to delete resource files downloaded in ~/.lanmp/resources?[Y/N]" afterdel
if [ "$afterdel" = "Y" ] || [ "$afterdel" = "y" ]; then
    rm -rf ~/.lanmp/resources/httpd*
    echo "Resources files deleted."
else
    echo "Installation finished without delete resource files."
fi

echo "==========================================="
echo "脚本已运行完成 Script Written by Junorz.com"
echo "==========================================="

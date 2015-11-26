#!/bin/bash
#====================================================================
# Pre-install Environment Install Script (Minimum)
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
read -p "Files in ~/.lanmp/resources must be deleted before installation, press Enter to continue or Ctrl+C to quit this script."
rm -rf ~/.lanmp/resources/libmcrypt*
rm -rf ~/.lanmp/resources/mcrypt*
rm -rf ~/.lanmp/resources/mhash*
rm -rf ~/.lanmp/resources/bison*
rm -rf ~/.lanmp/resources/cmake*
rm -rf ~/.lanmp/resources/pcre*
rm -rf ~/.lanmp/resources/apr*
rm -rf ~/.lanmp/resources/nginx*
rm -rf ~/.lanmp/resources/httpd*
rm -rf ~/.lanmp/resources/mariadb*
rm -rf ~/.lanmp/resources/php*

#通过Yum安装编译环境
yum -y install gcc gcc-c++ make wget unzip libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel curl curl-devel libtool libtool-ltdl-devel openssl-devel ncurses ncurses-devel libaio-devel cyrus-sasl-devel

#删除预安装项
yum -y remove mysql-server mysql mysql-libs
yum -y remove php-mysql
yum -y remove httpd*
yum -y remove php*
yum -y remove httpd
rm -rf /etc/my.cnf
rm -rf /usr/lib/mysql
rm -rf /usr/share/mysql

#添加系统库路径
echo "/usr/local/lib" >> /etc/ld.so.conf
ldconfig

#其他无法通过Yum安装的工具
#下载Libmcrypt,mhash,mcrypt
cd ~/.lanmp/resources
wget -O libmcrypt.tar.gz  http://sourceforge.net/projects/lanmp/files/libmcrypt-2.5.8.tar.gz/download
wget -O mcrypt.tar.gz http://sourceforge.net/projects/lanmp/files/mcrypt-2.6.8.tar.gz/download
wget -O mhash.tar.gz http://sourceforge.net/projects/lanmp/files/mhash-0.9.9.9.tar.gz/download
tar -zxf libmcrypt.tar.gz
tar -zxf mcrypt.tar.gz
tar -zxf mhash.tar.gz
cd ~/.lanmp/resources/libmcrypt*
./configure
make && make install
ldconfig
cd ~/.lanmp/resources/mhash*
./configure
make && make install
ldconfig
cd ~/.lanmp/resources/mcrypt*
./configure
make && make install

#安装pcre
cd ~/.lanmp/resources
wget -O pcre.tar.gz http://sourceforge.net/projects/pcre/files/pcre/8.37/pcre-8.37.tar.gz/download
tar -zxf pcre.tar.gz
cd ~/.lanmp/resources/pcre*
./configure
make && make install

#询问是否删除源文件
read -p "Do you want to delete all the source files downloaded in ~/.lanmp/resources?[Y/N]" delsource
if [ "$delsource" = "Y" ] || [ "$delsource" = "y" ]; then
	echo "Deleting,please wait..."
	rm -rf ~/.lanmp/resources/libmcrypt*
	rm -rf ~/.lanmp/resources/mcrypt*
	rm -rf ~/.lanmp/resources/mhash*
	rm -rf ~/.lanmp/resources/bison*
	rm -rf ~/.lanmp/resources/cmake*
	rm -rf ~/.lanmp/resources/pcre*
	rm -rf ~/.lanmp/resources/apr*
else
    echo "Installation finished without delete resource files."
fi

echo "==========================================="
echo "脚本已运行完成 Script Written by Junorz.com"
echo "==========================================="

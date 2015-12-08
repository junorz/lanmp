#!/bin/bash
#====================================================================
# Pre-install Environment Install Script (Minimum)
#
# Copyright (c) 2011-2015 Junorz.com All rights reserved.
#
# Intro: http://www.junorz.com/archives/374.html
#
#====================================================================

Preinstall_Min(){

#通过Yum安装编译环境
yum -y install epel-release
yum -y groupinstall "Development Tools"
yum -y install wget unzip libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel curl curl-devel libtool libtool-ltdl-devel openssl-devel ncurses ncurses-devel libaio-devel cyrus-sasl-devel jemalloc

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
#判断是否已经存在源文件
if [ ! -f "~/.lanmp/resources/libmcrypt.tar.gz" ] then
  wget -O libmcrypt.tar.gz  http://sourceforge.net/projects/lanmp/files/libmcrypt-2.5.8.tar.gz/download
fi
if [ ! -f "~/.lanmp/resources/mcrypt.tar.gz" ] then
  wget -O mcrypt.tar.gz http://sourceforge.net/projects/lanmp/files/mcrypt-2.6.8.tar.gz/download
fi
if [ ! -f "~/.lanmp/resources/mhash.tar.gz" ] then
  wget -O mhash.tar.gz http://sourceforge.net/projects/lanmp/files/mhash-0.9.9.9.tar.gz/download
fi
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
if [ ! -f "~/.lanmp/resources/pcre.tar.gz" ] then
  wget -O pcre.tar.gz http://sourceforge.net/projects/pcre/files/pcre/8.37/pcre-8.37.tar.gz/download
fi
tar -zxf pcre.tar.gz
cd ~/.lanmp/resources/pcre*
./configure
make && make install

}

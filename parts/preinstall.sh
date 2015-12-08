#!/bin/bash
#====================================================================
# Pre-install Environment Install Script
#
# Copyright (c) 2011-2015 Junorz.com All rights reserved.
#
# Intro: http://www.junorz.com/archives/374.html
#
#====================================================================

Preinstall(){

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
if [ ! -f "~/.lanmp/resources/libmcrypt.tar.gz" ]; then
  wget -O libmcrypt.tar.gz  http://sourceforge.net/projects/lanmp/files/libmcrypt-2.5.8.tar.gz/download
fi
if [ ! -f "~/.lanmp/resources/mcrypt.tar.gz" ]; then
  wget -O mcrypt.tar.gz http://sourceforge.net/projects/lanmp/files/mcrypt-2.6.8.tar.gz/download
fi
if [ ! -f "~/.lanmp/resources/mhash.tar.gz" ]; then
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

#安装bison
yum -y remove bison*
cd ~/.lanmp/resources
if [ ! -f "~/.lanmp/resources/bison.tar.gz" ]; then
  wget -O bison.tar.gz http://sourceforge.net/projects/lanmp/files/bison-3.0.4.tar.gz/download
fi
tar -zxf bison.tar.gz
cd ~/.lanmp/resources/bison*
./configure
make && make install

#安装pcre
cd ~/.lanmp/resources
if [ ! -f "~/.lanmp/resources/pcre.tar.gz" ]; then
  wget -O pcre.tar.gz http://sourceforge.net/projects/pcre/files/pcre/8.37/pcre-8.37.tar.gz/download
fi
tar -zxf pcre.tar.gz
cd ~/.lanmp/resources/pcre*
./configure
make && make install

#安装CMake
cd ~/.lanmp/resources
if [ ! -f "~/.lanmp/resources/cmake.tar.gz" ]; then
  wget -O cmake.tar.gz http://sourceforge.net/projects/lanmp/files/cmake-3.2.1.tar.gz/download
fi
tar -zxf cmake.tar.gz
cd ~/.lanmp/resources/cmake*
./bootstrap
make && make install

#安装APR
cd ~/.lanmp/resources
if [ ! -f "~/.lanmp/resources/apr.tar.gz" ]; then
  wget -O apr.tar.gz http://sourceforge.net/projects/lanmp/files/apr-1.5.1.tar.gz/download
fi
tar -zxf apr.tar.gz
cd apr*
./configure --prefix=/usr/local/apr
make && make install

#安装APR-util
cd ~/.lanmp/resources
if [ ! -f "~/.lanmp/resources/apr-util.tar.gz" ]; then
  wget -O apr-util.tar.gz http://sourceforge.net/projects/lanmp/files/apr-util-1.5.4.tar.gz/download
fi
tar -zxf apr-util.tar.gz
cd apr-util*
./configure --prefix=/usr/local/apr-util -with-apr=/usr/local/apr/bin/apr-1-config
make && make install

#更新系统库路径
echo "/usr/local/apr/lib" >> /etc/ld.so.conf
echo "/usr/local/apr-util/lib" >> /etc/ld.so.conf
ldconfig

}

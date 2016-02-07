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

#安装编译环境，然后移除自带软件
Dependence


#添加系统库路径
echo "/usr/local/lib" >> /etc/ld.so.conf
ldconfig


#安装Libmcrypt,mhash,mcrypt
cd ~/.lanmp/resources
#判断是否已经存在源文件
if [ ! -f ~/.lanmp/resources/libmcrypt.tar.gz ]; then
  wget -O libmcrypt.tar.gz  $libmcrypturl
fi
tar -zxf libmcrypt.tar.gz
cd ~/.lanmp/resources/libmcrypt*
./configure
make && make install
cd ~/.lanmp/resources/libltdl/
./configure --enable-ltdl-install
make && make install
ldconfig

if [ ! -f ~/.lanmp/resources/mcrypt.tar.gz ]; then
  wget -O mcrypt.tar.gz $mcrypturl
fi
tar -zxf mcrypt.tar.gz
cd ~/.lanmp/resources/mhash*
./configure
make && make install
ldconfig

if [ ! -f ~/.lanmp/resources/mhash.tar.gz ]; then
  wget -O mhash.tar.gz $mhashurl
fi
tar -zxf mhash.tar.gz
cd ~/.lanmp/resources/mcrypt*
./configure
make && make install
ldconfig

#安装pcre
cd ~/.lanmp/resources
if [ ! -f ~/.lanmp/resources/pcre.tar.gz ]; then
  wget -O pcre.tar.gz $pcreurl
fi
tar -zxf pcre.tar.gz
cd ~/.lanmp/resources/pcre*
./configure
make && make install

#安装CMake
cd ~/.lanmp/resources
if [ ! -f ~/.lanmp/resources/cmake.tar.gz ]; then
  wget -O cmake.tar.gz $cmakeurl
fi
tar -zxf cmake.tar.gz
cd ~/.lanmp/resources/cmake*
./bootstrap
make && make install

#安装APR
cd ~/.lanmp/resources
if [ ! -f ~/.lanmp/resources/apr.tar.gz ]; then
  wget -O apr.tar.gz $aprurl
fi
tar -zxf apr.tar.gz
cd apr*
./configure --prefix=/usr/local/apr
make && make install

#安装APR-util
cd ~/.lanmp/resources
if [ ! -f ~/.lanmp/resources/apr-util.tar.gz ]; then
  wget -O apr-util.tar.gz $aprutil_url
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

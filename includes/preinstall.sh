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

#安装pcre
cd ~/.lanmp/resources
if [ ! -f ~/.lanmp/resources/pcre.tar.gz ]; then
  wget -O pcre.tar.gz http://sourceforge.net/projects/pcre/files/pcre/8.37/pcre-8.37.tar.gz/download
fi
tar -zxf pcre.tar.gz
cd ~/.lanmp/resources/pcre*
./configure
make && make install

#安装CMake
cd ~/.lanmp/resources
if [ ! -f ~/.lanmp/resources/cmake.tar.gz ]; then
  wget -O cmake.tar.gz https://cmake.org/files/v3.4/cmake-3.4.1.tar.gz
fi
tar -zxf cmake.tar.gz
cd ~/.lanmp/resources/cmake*
./bootstrap
make && make install

#安装APR
cd ~/.lanmp/resources
if [ ! -f ~/.lanmp/resources/apr.tar.gz ]; then
  wget -O apr.tar.gz http://sourceforge.net/projects/lanmp/files/apr-1.5.1.tar.gz/download
fi
tar -zxf apr.tar.gz
cd apr*
./configure --prefix=/usr/local/apr
make && make install

#安装APR-util
cd ~/.lanmp/resources
if [ ! -f ~/.lanmp/resources/apr-util.tar.gz ]; then
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

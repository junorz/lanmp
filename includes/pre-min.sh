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

}

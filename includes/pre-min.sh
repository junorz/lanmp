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
if [ "$PM" = "yum" ]; then
    #安装编译环境
    yum -y install epel-release
    yum -y groupinstall "Development Tools"
    yum -y install wget unzip bison libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel curl curl-devel libtool libtool-ltdl-devel openssl-devel ncurses ncurses-devel libaio-devel cyrus-sasl-devel jemalloc
    #删除预安装项
    yum -y remove mysql-server mysql mysql-libs
    yum -y remove php-mysql
    yum -y remove httpd*
    yum -y remove php*
    yum -y remove httpd
    rm -rf /etc/my.cnf
    rm -rf /usr/lib/mysql
    rm -rf /usr/share/mysql

    #其他无法通过Yum安装的工具
    #下载Libmcrypt,mhash,mcrypt
    cd ~/.lanmp/resources
    #判断是否已经存在源文件
    if [ ! -f ~/.lanmp/resources/libmcrypt.tar.gz ]; then
      wget -O libmcrypt.tar.gz  http://sourceforge.net/projects/lanmp/files/libmcrypt-2.5.8.tar.gz/download
    fi
    if [ ! -f ~/.lanmp/resources/mcrypt.tar.gz ]; then
      wget -O mcrypt.tar.gz http://sourceforge.net/projects/lanmp/files/mcrypt-2.6.8.tar.gz/download
    fi
    if [ ! -f ~/.lanmp/resources/mhash.tar.gz ]; then
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


elif [ "$PM" = "apt" ]; then
    #安装编译环境（以下参考自lnmp.org）
    apt-get update -y
    apt-get autoremove -y
    apt-get -fy install
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y build-essential gcc g++ make
    for packages in build-essential gcc g++ make cmake autoconf automake re2c wget cron bzip2 libzip-dev libc6-dev file rcconf flex vim bison m4 gawk less cpp binutils diffutils unzip tar bzip2 libbz2-dev libncurses5 libncurses5-dev libtool libevent-dev openssl libssl-dev zlibc libsasl2-dev libltdl3-dev libltdl-dev zlib1g zlib1g-dev libbz2-1.0 libbz2-dev libglib2.0-0 libglib2.0-dev libpng3 libjpeg62 libjpeg62-dev libjpeg-dev libpng-dev libpng12-0 libpng12-dev libkrb5-dev curl libcurl3 libcurl3-gnutls libcurl4-gnutls-dev libcurl4-openssl-dev libpq-dev libpq5 gettext libjpeg-dev libpng12-dev libxml2-dev libcap-dev ca-certificates debian-keyring debian-archive-keyring libc-client2007e-dev psmisc patch git libc-ares-dev libicu-dev e2fsprogs libxslt libxslt1-dev libjemalloc-dev;
    do apt-get install -y $packages --force-yes; done
    #删除预安装项
    apt-get update -y
    for removepackages in apache2 apache2-doc apache2-utils apache2.2-common apache2.2-bin apache2-mpm-prefork apache2-doc apache2-mpm-worker mysql-client mysql-server mysql-common mysql-server-core-5.5 mysql-client-5.5 php5 php5-common php5-cgi php5-cli php5-mysql php5-curl php5-gd;
    do apt-get purge -y $removepackages; done
    killall apache2
    dpkg -l |grep apache
    dpkg -P apache2 apache2-doc apache2-mpm-prefork apache2-utils apache2.2-common
    dpkg -l |grep mysql
    dpkg -P mysql-server mysql-common libmysqlclient15off libmysqlclient15-dev
    dpkg -l |grep php
    dpkg -P php5 php5-common php5-cli php5-cgi php5-mysql php5-curl php5-gd
    apt-get autoremove -y && apt-get clean
fi

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

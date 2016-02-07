#!/bin/bash
#====================================================================
# Functions for LNMP/LAMP Auto Install Script
#
# Copyright (c) 2011-2015 Junorz.com All rights reserved.
#
# Intro: http://www.junorz.com/archives/374.html
#
#====================================================================
#询问要安装的Nginx版本
#版本号参照http://nginx.org/en/download.html
Nginx_Version(){
#判断是否已经存在源文件
if [ ! -f ~/.lanmp/resources/nginx.tar.gz ]; then
  echo "The version of Nginx can be referenced to http://nginx.org/en/download.html"
  read -p "Enter the version you want to install(1.8.1 by deafult):" vernginx
  if [ "$vernginx" = "" ]; then
	   vernginx="1.8.1"
  fi
  read -p "Do you want to install Nginx $vernginx?[Y/N]" ifinstallnginx
  if [ "$ifinstallnginx" = "Y" ] || [ "$ifinstallnginx" = "y" ]; then
	   echo "Trying downloading the Nginx..."
	    #尝试获取自定义的Nginx版本，若不成功，则退出
	     wget -O ~/.lanmp/resources/nginx.tar.gz http://nginx.org/download/nginx-$vernginx.tar.gz
	  if [ $? -ne 0 ]; then
		    echo "Nginx $vernginx cannot be downloaded.Please check if you have enter a correct version."
		    exit 1
	  fi
  else
    echo "Installation interrupted.Please try again."
    exit 1
  fi

fi
}

#询问MariaDB的Root密码
MariaDB_RootPassword(){
read -p "Enter a password for MariaDB root:" rootpwd
if [ "$rootpwd" = "" ]; then
	rootpwd="root"
fi
echo "=================================================="
echo "MariaDB root password will be set to:$rootpwd"
echo "=================================================="
}

#询问要安装的MariaDB版本
MariaDB_Version(){
#判断是否已经存在源文件
if [ ! -f ~/.lanmp/resources/mariadbin.tar.gz ]; then
  #下载二进制安装包
  if [ "$sysbit" = "32" ]; then
  	ldd --version
  	read -p "Is the version of glibc showed above over 2.14+?[Y/N]" verglibc
  	if [ "$verglibc" = "Y" ] || [ "$verglibc" = "y" ]; then
  		wget -O ~/.lanmp/resources/mariadbin.tar.gz http://sourceforge.net/projects/lanmp/files/MariaDB-10.1.11/mariadb-10.1.11-linux-glibc_214-i686.tar.gz
  	elif [ "$verglibc" = "N" ] || [ "$verglibc" = "n" ]; then
  		wget -O ~/.lanmp/resources/mariadbin.tar.gz http://sourceforge.net/projects/lanmp/files/MariaDB-10.1.11/mariadb-10.1.11-linux-i686.tar.gz
  	else
  		echo "Please enter Y or N.Try to run this script again."
  		exit 1
  	fi
  elif [ "$sysbit" = "64" ]; then
  	ldd --version
  	read -p "Is the version of glibc showed above over 2.14+?[Y/N]" verglibc
  	if [ "$verglibc" = "Y" ] || [ "$verglibc" = "y" ]; then
  		wget -O ~/.lanmp/resources/mariadbin.tar.gz http://sourceforge.net/projects/lanmp/files/MariaDB-10.1.11/mariadb-10.1.11-linux-glibc_214-x86_64.tar.gz
  	elif [ "$verglibc" = "N" ] || [ "$verglibc" = "n" ]; then
  		wget -O ~/.lanmp/resources/mariadbin.tar.gz http://sourceforge.net/projects/lanmp/files/MariaDB-10.1.11/mariadb-10.1.11-linux-x86_64.tar.gz
  	else
  		echo "Please enter Y or N.Try to run this script again."
  		exit 1
  	fi
  else
  	echo "Cannot detect your system's type.Please enter a legal value."
  	exit 1
  fi
fi
}

#判断系统是32还是64位
#注：这条函数来自lnmp.org
Get_OS_Bit()
{
    if [[ `getconf WORD_BIT` = '32' && `getconf LONG_BIT` = '64' ]] ; then
        sysbit='64'
    else
        sysbit='32'
    fi
}

#判断系统类型
#注：这条函数来自lnmp.org
Get_Dist_Name()
{
    if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        DISTRO='CentOS'
        PM='yum'
    elif grep -Eqi "Red Hat Enterprise Linux Server" /etc/issue || grep -Eq "Red Hat Enterprise Linux Server" /etc/*-release; then
        DISTRO='RHEL'
        PM='yum'
    elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun" /etc/*-release; then
        DISTRO='Aliyun'
        PM='yum'
    elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release; then
        DISTRO='Fedora'
        PM='yum'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        DISTRO='Debian'
        PM='apt'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        DISTRO='Ubuntu'
        PM='apt'
    elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release; then
        DISTRO='Raspbian'
        PM='apt'
    else
        DISTRO='unknow'
    fi
    Get_OS_Bit
}

Dependence(){
#安装编译环境，然后移除自带软件
if [ "$PM" = "yum" ]; then
    #安装编译环境
    yum -y install epel-release
    yum -y groupinstall "Development Tools"
    yum -y install gcc-c++ wget unzip bison libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel curl curl-devel libtool libtool-ltdl-devel openssl-devel ncurses ncurses-devel libaio-devel cyrus-sasl-devel jemalloc chkconfig
    #删除预安装项
    yum -y remove mysql-server mysql mysql-libs
    yum -y remove php-mysql
    yum -y remove httpd*
    yum -y remove php*
    yum -y remove httpd
    rm -rf /etc/my.cnf
    rm -rf /usr/lib/mysql
    rm -rf /usr/share/mysql

elif [ "$PM" = "apt" ]; then
    #安装编译环境（Debian编译环境参考自lnmp.org）
    apt-get update -y
    apt-get autoremove -y
    apt-get -fy install
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y build-essential gcc g++ make
    for packages in build-essential gcc g++ make cmake autoconf automake re2c wget cron bzip2 libzip-dev libc6-dev file rcconf flex vim bison m4 gawk less cpp binutils diffutils unzip tar bzip2 libbz2-dev libncurses5 libncurses5-dev libtool libevent-dev openssl libssl-dev zlibc libsasl2-dev libltdl3-dev libltdl-dev zlib1g zlib1g-dev libbz2-1.0 libbz2-dev libglib2.0-0 libglib2.0-dev libpng3 libjpeg62 libjpeg62-dev libjpeg-dev libpng-dev libpng12-0 libpng12-dev libkrb5-dev curl libcurl3 libcurl3-gnutls libcurl4-gnutls-dev libcurl4-openssl-dev libpq-dev libpq5 gettext libjpeg-dev libpng12-dev libxml2-dev libcap-dev ca-certificates debian-keyring debian-archive-keyring libc-client2007e-dev psmisc patch git libc-ares-dev libicu-dev e2fsprogs libxslt libxslt1-dev libjemalloc-dev libaio-dev libfreetype6-dev;
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
}

StartInstallation(){
  echo "Installation is ready. Press Enter to start the installation."
  read -p "Or Press Ctrl+C to exit."
}

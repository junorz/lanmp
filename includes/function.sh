#!/bin/bash
#====================================================================
# Functions for LNMP/LAMP Auto Install Script
#
# Copyright (c) 2011-2015 Junorz.com All rights reserved.
#
# Intro: http://www.junorz.com/archives/374.html
#
#====================================================================
#询问一些安装参数

#询问要安装的Nginx版本
#版本号参照http://nginx.org/en/download.html
Nginx_Version(){
#判断是否已经存在源文件
if [ ! -f ~/.lanmp/resources/nginx.tar.gz ]; then
  echo "The version of Nginx can be referenced to http://nginx.org/en/download.html"
  read -p "Enter the version you want to install(1.8.0 by deafult):" vernginx
  if [ "$vernginx" = "" ]; then
	   vernginx="1.8.0"
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
  read -p "Is your system 32bit or 64bit?(Enter 32 or 64)" sysbit
  if [ "$sysbit" = "32" ]; then
  	yum -y install glibc
  	rpm -qa|grep glibc
  	read -p "Is the version of glibc showed above over 2.14+?[Y/N]" verglibc
  	if [ "$verglibc" = "Y" ] || [ "$verglibc" = "y" ]; then
  		wget -O ~/.lanmp/resources/mariadbin.tar.gz https://downloads.mariadb.org/f/mariadb-10.1.9/bintar-linux-glibc_214-x86/mariadb-10.1.9-linux-glibc_214-i686.tar.gz
  	elif [ "$verglibc" = "N" ] || [ "$verglibc" = "n" ]; then
  		wget -O ~/.lanmp/resources/mariadbin.tar.gz https://downloads.mariadb.org/f/mariadb-10.1.9/bintar-linux-x86/mariadb-10.1.9-linux-i686.tar.gz
  	else
  		echo "Please enter Y or N.Try to run this script again."
  		exit 1
  	fi
  elif [ "$sysbit" = "64" ]; then
  	yum -y install glibc
  	rpm -qa|grep glibc
  	read -p "Is the version of glibc showed above over 2.14+?[Y/N]" verglibc
  	if [ "$verglibc" = "Y" ] || [ "$verglibc" = "y" ]; then
  		wget -O ~/.lanmp/resources/mariadbin.tar.gz https://downloads.mariadb.org/f/mariadb-10.1.9/bintar-linux-glibc_214-x86_64/mariadb-10.1.9-linux-glibc_214-x86_64.tar.gz
  	elif [ "$verglibc" = "N" ] || [ "$verglibc" = "n" ]; then
  		wget -O ~/.lanmp/resources/mariadbin.tar.gz https://downloads.mariadb.org/f/mariadb-10.1.9/bintar-linux-x86_64/mariadb-10.1.9-linux-x86_64.tar.gz
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

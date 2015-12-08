#!/bin/bash
#====================================================================
# LNMP/LAMP Auto Install Script
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
read -p "Would you want to delete all files in ~/.lanmp/resources? [Y/N]" deleteresources
if [ "$deleteresources" = "Y" ] || [ "$deleteresources" = "y" ]; then
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
else
  read -p ".tar.gz files in ~/.lanmp/resources will be used for Installing. Press Enter to continue, or Ctrl+C to exit the installation."
  rm -rf ~/.lanmp/resources/libmcrypt-*
  rm -rf ~/.lanmp/resources/mcrypt-*
  rm -rf ~/.lanmp/resources/mhash-*
  rm -rf ~/.lanmp/resources/bison-*
  rm -rf ~/.lanmp/resources/cmake-*
  rm -rf ~/.lanmp/resources/pcre-*
  rm -rf ~/.lanmp/resources/apr-*
  rm -rf ~/.lanmp/resources/nginx-*
  rm -rf ~/.lanmp/resources/httpd-*
  rm -rf ~/.lanmp/resources/mariadb-*
  rm -rf ~/.lanmp/resources/php-*
fi


#检查用户需要安装什么
WhatInstall="Noinstall"
case "$1" in
    lnmp)
        read -p "Do you want to install Nginx+MariaDB+PHP?[Y/N]" ifinstall
        if [ "$ifinstall" = "Y" ] || [ "$ifinstall" = "y" ]; then
            WhatInstall="lnmp"
        else
            exit 1
        fi
    ;;
    lamp)
        read -p "Do you want to install Apache+MariaDB+PHP?[Y/N]" ifinstall
        if [ "$ifinstall" = "Y" ] || [ "$ifinstall" = "y" ]; then
            WhatInstall="lamp"
        else
            exit 1
        fi
    ;;
    pre)
        read -p "Do you want to install Combine Environment?[Y/N]" ifinstall
        if [ "$ifinstall" = "Y" ] || [ "$ifinstall" = "y" ]; then
            WhatInstall="pre"
        else
            exit 1
        fi
    ;;
    premin)
        read -p "Do you want to install the Minimal Combine Environment?[Y/N]" ifinstall
        if [ "$ifinstall" = "Y" ] || [ "$ifinstall" = "y" ]; then
            WhatInstall="premin"
        else
            exit 1
        fi
    ;;
    nginx)
        read -p "Do you want to install Nginx only?[Y/N]" ifinstall
        if [ "$ifinstall" = "Y" ] || [ "$ifinstall" = "y" ]; then
            WhatInstall="nginx"
        else
            exit 1
        fi
    ;;
    apache)
        read -p "Do you want to install apache only?[Y/N]" ifinstall
        if [ "$ifinstall" = "Y" ] || [ "$ifinstall" = "y" ]; then
            WhatInstall="apache"
        else
            exit 1
        fi
    ;;
    mariadb)
        read -p "Do you want to install MariaDB only(The Combine Version)?[Y/N]" ifinstall
        if [ "$ifinstall" = "Y" ] || [ "$ifinstall" = "y" ]; then
            WhatInstall="mariadb"
        else
            exit 1
        fi
    ;;
    mariadbin)
        read -p "Do you want to install MariaDB only(The binary Version)?[Y/N]" ifinstall
        if [ "$ifinstall" = "Y" ] || [ "$ifinstall" = "y" ]; then
            WhatInstall="mariadbin"
        else
            exit 1
        fi
    ;;
    phpnginx)
        read -p "Do you want to install PHP with Nginx only?[Y/N]" ifinstall
        if [ "$ifinstall" = "Y" ] || [ "$ifinstall" = "y" ]; then
            WhatInstall="phpnginx"
        else
            exit 1
        fi
    ;;
    phpapache)
        read -p "Do you want to install PHP with Nginx only?[Y/N]" ifinstall
        if [ "$ifinstall" = "Y" ] || [ "$ifinstall" = "y" ]; then
            WhatInstall="phpapache"
        else
            exit 1
        fi
    ;;
    *)
        echo "illegal value. Please look https://github.com/junorz/lanmp for help."
        exit 1
    ;;
esac

echo "Starting Installation..."

#询问一些安装参数
#询问要安装的Nginx版本
#版本号参照http://nginx.org/en/download.html
Nginx_Version(){
#判断是否已经存在源文件
if [ ! -f "~/.lanmp/resources/nginx.tar.gz" ]; then
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
if [ ! -f "~/.lanmp/resources/mariadbin.tar.gz" ]; then
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

#引用安装文件
. parts/preinstall.sh
. parts/pre-min.sh
. parts/nginx.sh
. parts/apache.sh
. parts/mariadb.sh
. parts/mariadb-bin.sh
. parts/php-nginx.sh
. parts/php-apache.sh

#开始安装过程
#检查用户需要安装什么
if [ "$WhatInstall" = "lnmp" ]; then
      Nginx_Version
      MariaDB_RootPassword
      MariaDB_Version
      Preinstall_Min
      Install_Nginx
      Install_MariaDBin
      Install_PHPwithNginx
elif [ "$WhatInstall" = "lamp" ]; then
      Nginx_Version
      MariaDB_RootPassword
      MariaDB_Version
      Preinstall
      Install_Apache
      Install_MariaDBin
      Install_PHPwithApache
elif [ "$WhatInstall" = "pre" ]; then
      Preinstall
elif [ "$WhatInstall" = "premin" ]; then
      Preinstall_Min
elif [ "$WhatInstall" = "nginx" ]; then
      Nginx_Version
      Install_Nginx
elif [ "$WhatInstall" = "apache" ]; then
      Install_Apache
elif [ "$WhatInstall" = "mariadb" ]; then
      MariaDB_RootPassword
      Install_MairaDB
elif [ "$WhatInstall" = "mariadbin" ]; then
      MariaDB_Version
      MariaDB_RootPassword
      Install_MariaDBin
elif [ "$WhatInstall" = "phpnginx" ]; then
      Install_PHPwithNginx
elif [ "$WhatInstall" = "phpapache" ]; then
      Install_PHPwithApache
else
      exit 1
fi

echo "========================================================================="
echo "所有脚本已执行完毕！"
echo "Script Written by Junorz.com"
echo "========================================================================="

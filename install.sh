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

#引用安装文件
. ~/.lanmp/includes/functions.sh
. ~/.lanmp/includes/preinstall.sh
. ~/.lanmp/includes/pre-min.sh
. ~/.lanmp/includes/nginx.sh
. ~/.lanmp/includes/apache.sh
. ~/.lanmp/includes/mariadb.sh
. ~/.lanmp/includes/mariadb-bin.sh
. ~/.lanmp/includes/php-nginx.sh
. ~/.lanmp/includes/php-apache.sh

#获取系统类型
Get_Dist_Name

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

#开始安装过程
#检查用户需要安装什么
if [ "$WhatInstall" = "lnmp" ]; then
      Nginx_Version
      MariaDB_RootPassword
      MariaDB_Version
      StartInstallation
      Preinstall_Min
      Install_Nginx
      Install_MariaDBin
      Install_PHPwithNginx
elif [ "$WhatInstall" = "lamp" ]; then
      Nginx_Version
      MariaDB_RootPassword
      MariaDB_Version
      StartInstallation
      Preinstall
      Install_Apache
      Install_MariaDBin
      Install_PHPwithApache
elif [ "$WhatInstall" = "pre" ]; then
      StartInstallation
      Preinstall
elif [ "$WhatInstall" = "premin" ]; then
      StartInstallation
      Preinstall_Min
elif [ "$WhatInstall" = "nginx" ]; then
      Nginx_Version
      StartInstallation
      Install_Nginx
elif [ "$WhatInstall" = "apache" ]; then
      StartInstallation
      Install_Apache
elif [ "$WhatInstall" = "mariadb" ]; then
      MariaDB_RootPassword
      StartInstallation
      Install_MairaDB
elif [ "$WhatInstall" = "mariadbin" ]; then
      MariaDB_Version
      MariaDB_RootPassword
      StartInstallation
      Install_MariaDBin
elif [ "$WhatInstall" = "phpnginx" ]; then
      StartInstallation
      Install_PHPwithNginx
elif [ "$WhatInstall" = "phpapache" ]; then
      StartInstallation
      Install_PHPwithApache
else
      exit 1
fi

echo "========================================================================="
echo "所有脚本已执行完毕！"
echo "Script Written by Junorz.com"
echo "========================================================================="

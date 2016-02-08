#!/bin/bash
#====================================================================
# LANMP Uninstall Script
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

. ~/.lanmp/includes/functions.sh
Get_Dist_Name

echo "==========================================="
echo "1 - Nginx"
echo "2 - Apache"
echo "3 - MariaDB"
echo "4 - PHP-with-Nginx"
echo "5 - PHP-with-Apache"
echo "6 - LNMP"
echo "7 - LAMP"
echo "==========================================="

read -p "Which one would you uninstall?" uninst
if [ "$uninst" = 1 ]; then
	echo "Uninstalling Nginx..."
  UninstallNginx
	echo "Nginx Uninstalled"
elif [ "$uninst" = 2 ]; then
	echo "Uninstalling Apache..."
	UninstallApache
	echo "Apache Uninstalled"
elif [ "$uninst" = 3 ]; then
	echo "Uninstalling MariaDB..."
	UninstallMariaDB
	echo "MariaDB Uninstalled"
elif [ "$uninst" = 4 ]; then
	echo "Uninstalling PHP-with-Nginx"
	Uninstall_PHP_with_Nginx
	echo "PHP-with-Nginx Uninstalled"
elif [ "$uninst" = 5 ]; then
	echo "Uninstalling PHP-with-Apache"
	Uninstall_PHP_with_Apache
	echo "PHP-with-Apache Uninstalled"
elif [ "$uninst" = 6 ]; then
	echo "Uninstalling LNMP"
	UninstallNginx
  UninstallMariaDB
  Uninstall_PHP_with_Nginx
	echo "LNMP Uninstalled"
elif [ "$uninst" = 7 ]; then
	echo "Uninstalling LAMP"
	UninstallNginx
  UninstallMariaDB
  Uninstall_PHP_with_Apache
	echo "LAMP Uninstalled"
else
	echo "Please input 1-7.Try to run this script again."
	exit 1
fi

echo "==========================================="
echo "脚本已运行完成 Script Written by Junorz.com"
echo "==========================================="

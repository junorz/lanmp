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
	echo "卸载Nginx"
	nginx -s stop
	rm -rf /usr/bin/nginx
	rm -rf /usr/local/nginx
	rm -rf /root/nginx*
	sed -i "/nginx/d" /etc/rc.d/rc.local
elif [ "$uninst" = 2 ]; then
	echo "卸载Apache"
	service httpd stop
	chkconfig --del httpd
	rm -rf /etc/init.d/httpd
	rm -rf /usr/local/apache
	rm -rf /root/httpd*
elif [ "$uninst" = 3 ]; then
	echo "卸载MariaDB"
	service mysqld stop
	chkconfig --del mysqld
	rm -rf /etc/init.d/mysqld
	rm -rf /usr/local/mysql
	rm -rf /etc/my.cnf
	rm -rf /root/mariadb*
	sed -i "/mysql/d" /etc/ld.so.conf
	ldconfig
elif [ "$uninst" = 4 ]; then
	echo "卸载PHP-with-Nginx"
	pkill php
	sed -i "/php/d" /etc/rc.d/rc.local
	rm -rf /usr/local/php
	rm -rf /root/php*
	rm -rf /usr/local/nginx/conf/nginx.conf
	cp /usr/local/nginx/conf/nginx-backup.conf -rf /usr/local/nginx/conf/nginx.conf
elif [ "$uninst" = 5 ]; then
	echo "卸载PHP-with-Apache"
	sed -i "/<FilesMatch \\\.php\$>/N;/.*SetHandler application\/x-httpd-php/N;/<\/FilesMatch>/d" /usr/local/apache/conf/httpd.conf
	sed -i "/modules\/libphp5.so/d" /usr/local/apache/conf/httpd.conf
	rm -rf /usr/local/php
	rm -rf /root/php*
elif [ "$uninst" = 6 ]; then
	echo "卸载LNMP"
	nginx -s stop
	rm -rf /usr/bin/nginx
	rm -rf /usr/local/nginx
	rm -rf /root/nginx*
	sed -i "/nginx/d" /etc/rc.d/rc.local
	
	service mysqld stop
	chkconfig --del mysqld
	rm -rf /etc/init.d/mysqld
	rm -rf /usr/local/mysql
	rm -rf /etc/my.cnf
	rm -rf /root/mariadb*
	
	pkill php
	sed -i "/php/d" /etc/rc.d/rc.local
	rm -rf /usr/local/php
	rm -rf /root/php*
	
	sed -i "/\/usr\/local\/lib/d" /etc/ld.so.conf
	sed -i "/apr/d" /etc/ld.so.conf
	sed -i "/mysql/d" /etc/ld.so.conf
	ldconfig
elif [ "$uninst" = 7 ]; then
	echo "卸载LAMP"
	service httpd stop
	chkconfig --del httpd
	rm -rf /etc/init.d/httpd
	rm -rf /usr/local/apache
	rm -rf /root/httpd*
	
	service mysqld stop
	chkconfig --del mysqld
	rm -rf /etc/init.d/mysqld
	rm -rf /usr/local/mysql
	rm -rf /etc/my.cnf
	rm -rf /root/mariadb*
	
	rm -rf /usr/local/php
	rm -rf /root/php*
	
	sed -i "/\/usr\/local\/lib/d" /etc/ld.so.conf
	sed -i "/apr/d" /etc/ld.so.conf
	sed -i "/mysql/d" /etc/ld.so.conf
	ldconfig
else
	echo "Please input 1-7.Try to run this script again."
	exit 1
fi

echo "==========================================="
echo "脚本已运行完成 Script Written by Junorz.com"
echo "==========================================="

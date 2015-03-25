#!/bin/bash
#====================================================================
# MariaDB binary Installation Auto Install Script
#
# Copyright (c) 2011-2015 Junorz.com All rights reserved.
# 
# Intro: http://www.junorz.com/archives/374.html
#
# 为了配合以往的习惯，以及官方文档，因此MariaDB安装在/usr/local/mysql
# 其他地方也没有特意地将MySQL换成MariaDB
#====================================================================

# 检查是否为管理员
if [ $(id -u) != "0" ]; then
    echo "Please login as root to run this script"
    exit 1
fi

#安装前删除resources文件夹下的源文件
read -p "Mariadb resource files in ~/.lanmp/resources must be deleted before installation, press Enter to continue or Ctrl+C to quit this script."
rm -rf ~/.lanmp/resources/mariadb*

#询问用户设置默认密码
read -p "Enter a password for MariaDB root:" rootpwd
if [ "$rootpwd" = "" ]; then
	rootpwd="root"
fi
echo "=================================================="
echo "MariaDB root password will be set to:$rootpwd"
echo "=================================================="

#下载二进制安装包
read -p "Is your system 32bit or 64bit?(Enter 32 or 64)" sysbit
if [ "$sysbit" = "32" ]; then
	yum -y install glibc
	rpm -qa|grep glibc
	read -p "Is the version of glibc showed above over 2.14+?[Y/N]" verglibc
	if [ "$verglibc" = "Y" ] || [ "$verglibc" = "y" ]; then
		wget -O ~/.lanmp/resources/mariadb.tar.gz http://sourceforge.net/projects/lanmp/files/mariadb-10.0.17-linux-glibc_214-i686.tar.gz/download
	elif [ "$verglibc" = "N" ] || [ "$verglibc" = "n" ]; then
		wget -O ~/.lanmp/resources/mariadb.tar.gz http://sourceforge.net/projects/lanmp/files/mariadb-10.0.17-linux-i686.tar.gz/download
	else
		echo "Please enter Y or N.Try to run this script again."
		exit 1
	fi
elif [ "$sysbit" = "64" ]; then
	yum -y install glibc
	rpm -qa|grep glibc
	read -p "Is the version of glibc showed above over 2.14+?[Y/N]" verglibc
	if [ "$verglibc" = "Y" ] || [ "$verglibc" = "y" ]; then
		wget -O ~/.lanmp/resources/mariadb.tar.gz http://sourceforge.net/projects/lanmp/files/mariadb-10.0.17-linux-glibc_214-x86_64.tar.gz/download
	elif [ "$verglibc" = "N" ] || [ "$verglibc" = "n" ]; then
		wget -O ~/.lanmp/resources/mariadb.tar.gz http://sourceforge.net/projects/lanmp/files/mariadb-10.0.17-linux-x86_64.tar.gz/download
	else
		echo "Please enter Y or N.Try to run this script again."
		exit 1
	fi
else
	echo "Cannot detect your system's type.Please enter a legal value."
	exit 1
fi

#解压到相应目录
echo "Extracting Mariadb.tar.gz....."
tar -zxf ~/.lanmp/mariadb.tar.gz -C /usr/local
mv /usr/local/mariadb-* /usr/local/mysql

#创建运行Mariadb进程的用户
groupadd mysql
useradd -r -g mysql mysql

#使用my-medium.cnf，可以根据实际情况更改
chown -R mysql /usr/local/mysql/
cp /usr/local/mysql/support-files/my-medium.cnf /etc/my.cnf

#初始化数据库
/usr/local/mysql/scripts/mysql_install_db --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data
chown -R root /usr/local/mysql
chown -R mysql /usr/local/mysql/data

#开机自启动
cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
chkconfig --add mysqld

#设置系统库路径
echo "/usr/local/mysql/lib" >> /etc/ld.so.conf
ldconfig

#启动服务
service mysqld start

#设置管理员密码
/usr/local/mysql/bin/mysqladmin -u root password $rootpwd

#询问是否删除源文件
read -p "Would you like to delete resource files downloaded in ~/.lanmp/resources?[Y/N]" afterdel
if [ "$afterdel" = "Y" ] || [ "$afterdel" = "y" ]; then
    rm -rf ~/.lanmp/resources/mariadb*
    echo "Resources files deleted."
else
    echo "Installation finished without delete resource files."
fi

echo "==========================================="
echo "脚本已运行完成 Script Written by Junorz.com"
echo "==========================================="

#!/bin/bash
#Welcome http://www.junorz.com
#为了配合以往的习惯，以及官方文档，因此MariaDB安装在/usr/local/mysql下
#其他地方也没有特意地将MySQL换成MariaDB

# 检查是否为管理员
if [ $(id -u) != "0" ]; then
    echo "Please login as root to run this script"
    exit 1
fi

#创建运行Mariadb进程的用户
groupadd mysql
useradd -r -g mysql mysql

#下载编译
cd /root
wget -O mariadb.tar.gz http://sourceforge.net/projects/lanmp/files/mariadb-10.0.17.tar.gz/download
tar -zxf mariadb.tar.gz
cd mariadb*
cmake .
make && make install

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

#设置管理员密码
read -p "Enter a password for root:" rootpwd
if [ "$rootpwd" = "" ]; then
	rootpwd="root"
fi
/usr/local/mysql/bin/mysqladmin -u root password $rootpwd
echo "MariaDB root password has set to:$rootpwd"

#启动服务
service mysqld start


echo "============================================================================="
echo "Mariadb已安装完成，请运行其他安装脚本 Script Written by Junorz.com"
echo "============================================================================="

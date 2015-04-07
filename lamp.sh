#!/bin/bash
#====================================================================
# Centos + Apache + MariaDB + PHP Auto Install Script
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

#移除resources文件夹下的源文件
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

#================================读取用户输入==================================
#判断需要安装的MariaDB版本
read -p "Is your system 32bit or 64bit?(Enter 32 or 64)" sysbit
if [ "$sysbit" = "32" ]; then
	yum -y install glibc
	rpm -qa|grep glibc
	read -p "Is the version of glibc showed above over 2.14+?[Y/N]" verglibc
	if [ "$verglibc" = "Y" ] || [ "$verglibc" = "y" ]; then
		echo "MariaDB-32bit-withGlibc2.14 will be installed."
	elif [ "$verglibc" = "N" ] || [ "$verglibc" = "n" ]; then
		echo "MariaDB-32bit-withoutGlibc2.14 will be installed."
	else
		echo "Please enter Y or N.Try to run this script again."
		exit 1
	fi
elif [ "$sysbit" = "64" ]; then
	yum -y install glibc
	rpm -qa|grep glibc
	read -p "Is the version of glibc showed above over 2.14+?[Y/N]" verglibc
	if [ "$verglibc" = "Y" ] || [ "$verglibc" = "y" ]; then
		echo "MariaDB-64bit-withGlibc2.14 will be installed."
	elif [ "$verglibc" = "N" ] || [ "$verglibc" = "n" ]; then
		echo "MariaDB-64bit-withoutGlibc2.14 will be installed."
	else
		echo "Please enter Y or N.Try to run this script again."
		exit 1
	fi
else
	echo "Cannot detect your system's type.Please enter a legal value."
	exit 1
fi

#MariaDB密码
read -p "Enter a password for MariaDB root:" rootpwd
if [ "$rootpwd" = "" ]; then
	rootpwd="root"
fi
echo "=================================================="
echo "MariaDB root password will be  set to:$rootpwd"
echo "=================================================="

#================================安装编译环境==================================

#通过Yum安装编译环境
yum -y groupinstall "Development Tools"
yum -y install wget unzip libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel curl curl-devel libtool libtool-ltdl-devel openssl-devel ncurses ncurses-devel libaio* cyrus-sasl-devel

#删除预安装项
yum -y remove mysql-server mysql mysql-libs
yum -y remove php-mysql
yum -y remove httpd*
yum -y remove php*
yum -y remove httpd
rm -rf /etc/my.cnf
rm -rf /usr/lib/mysql
rm -rf /usr/share/mysql

#添加系统库路径
echo "/usr/local/lib" >> /etc/ld.so.conf
ldconfig

#其他无法通过Yum安装的工具
#下载Libmcrypt,mhash,mcrypt
cd ~/.lanmp/resources
wget -O libmcrypt.tar.gz  http://sourceforge.net/projects/lanmp/files/libmcrypt-2.5.8.tar.gz/download
wget -O mcrypt.tar.gz http://sourceforge.net/projects/lanmp/files/mcrypt-2.6.8.tar.gz/download
wget -O mhash.tar.gz http://sourceforge.net/projects/lanmp/files/mhash-0.9.9.9.tar.gz/download
tar -zxf libmcrypt.tar.gz
tar -zxf mcrypt.tar.gz
tar -zxf mhash.tar.gz
cd ~/.lanmp/resources/libmcrypt*
./configure
make && make install
cd ~/.lanmp/resources/mhash*
./configure
make && make install
cd ~/.lanmp/resources/mcrypt*
./configure
make && make install

#安装pcre
cd ~/.lanmp/resources/
wget -O pcre.tar.gz http://sourceforge.net/projects/lanmp/files/pcre-8.36.tar.gz/download
tar -zxf pcre.tar.gz
cd ~/.lanmp/resources/pcre*
./configure
make && make install

#安装APR
cd ~/.lanmp/resources
wget -O apr.tar.gz http://sourceforge.net/projects/lanmp/files/apr-1.5.1.tar.gz/download
tar -zxf apr.tar.gz
cd apr*
./configure --prefix=/usr/local/apr
make && make install

#安装APR-util
cd ~/.lanmp/resources
wget -O apr-util.tar.gz http://sourceforge.net/projects/lanmp/files/apr-util-1.5.4.tar.gz/download
tar -zxf apr-util.tar.gz
cd apr-util*
./configure --prefix=/usr/local/apr-util -with-apr=/usr/local/apr/bin/apr-1-config
make && make install

#更新系统库路径
echo "/usr/local/apr/lib" >> /etc/ld.so.conf
echo "/usr/local/apr-util/lib" >> /etc/ld.so.conf
ldconfig

#================================安装Apache==================================
#创建运行Apache的用户
groupadd www
useradd -M -s /sbin/nologin -g www www

#下载编译
cd ~/.lanmp/resources
wget -O httpd.tar.gz  http://sourceforge.net/projects/lanmp/files/httpd-2.4.12.tar.gz/download
tar -zxf httpd.tar.gz
cd httpd*
./configure --prefix=/usr/local/apache \
--with-apr=/usr/local/apr/bin/apr-1-config \
--with-apr-util=/usr/local/apr-util/bin/apu-1-config \
--enable-so \
--enable-rewrite \
--enable-ssl \
--enable-mods-shared=all \
--enable-expires \
--with-mpm=prefork
make && make install

#配置httpd.conf文件
sed -i "s/User daemon/User www/g" /usr/local/apache/conf/httpd.conf
sed -i "s/Group daemon/Group www/g" /usr/local/apache/conf/httpd.conf
sed -i "s/#ServerName www.example.com:80/ServerName localhost/g" /usr/local/apache/conf/httpd.conf
sed -i "2 a #chkconfig:345 85 15" /usr/local/apache/bin/apachectl
sed -i "3 a #description:httpd" /usr/local/apache/bin/apachectl

#添加服务
cp /usr/local/apache/bin/apachectl /etc/init.d/httpd
chkconfig --add httpd

#================================安装MariaDB二进制版本==================================
cd ~/.lanmp/resources
#下载相应版本
if [ "$sysbit" = "32" ]; then
	if [ "$verglibc" = "Y" ] || [ "$verglibc" = "y" ]; then
		wget -O ~/.lanmp/resources/mariadb.tar.gz http://sourceforge.net/projects/lanmp/files/mariadb-10.0.17-linux-glibc_214-i686.tar.gz/download
	elif [ "$verglibc" = "N" ] || [ "$verglibc" = "n" ]; then
		wget -O ~/.lanmp/resources/mariadb.tar.gz http://sourceforge.net/projects/lanmp/files/mariadb-10.0.17-linux-i686.tar.gz/download
	fi
elif [ "$sysbit" = "64" ]; then
	if [ "$verglibc" = "Y" ] || [ "$verglibc" = "y" ]; then
		wget -O ~/.lanmp/resources/mariadb.tar.gz http://sourceforge.net/projects/lanmp/files/mariadb-10.0.17-linux-glibc_214-x86_64.tar.gz/download
	elif [ "$verglibc" = "N" ] || [ "$verglibc" = "n" ]; then
		wget -O ~/.lanmp/resources/mariadb.tar.gz http://sourceforge.net/projects/lanmp/files/mariadb-10.0.17-linux-x86_64.tar.gz/download
	fi
fi

#解压到相应目录
echo "Extracting Mariadb.tar.gz....."
tar -zxf mariadb.tar.gz -C /usr/local
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

#================================安装PHP==================================
#下载编译
cd ~/.lanmp/resources
wget -O php.tar.gz http://sourceforge.net/projects/lanmp/files/php-5.6.7.tar.gz/download
tar -zxf php.tar.gz
cd php*
./configure --prefix=/usr/local/php \
--with-config-file-path=/usr/local/php/etc \
--enable-fpm \
--with-fpm-user=www \
--with-fpm-group=www \
--with-apxs2=/usr/local/apache/bin/apxs \
--with-mysql=/usr/local/mysql \
--with-mysqli=/usr/local/mysql/bin/mysql_config \
--with-pdo-mysql=/usr/local/mysql \
--with-iconv-dir \
--with-freetype-dir \
--with-jpeg-dir \
--with-png-dir \
--with-zlib \
--with-libxml-dir \
--enable-xml \
--disable-rpath \
--enable-bcmath \
--enable-shmop \
--enable-sysvsem \
--enable-inline-optimization \
--with-curl \
--enable-mbregex \
--enable-mbstring \
--with-mcrypt \
--enable-ftp \
--with-gd \
--enable-gd-native-ttf \
--with-openssl \
--with-mhash \
--enable-pcntl \
--enable-sockets \
--with-xmlrpc \
--enable-zip \
--enable-soap \
--with-gettext
make && make install

#复制配置文件
cp php.ini-development /usr/local/php/etc/php.ini

#配置httpd.conf文件
cat >> /usr/local/apache/conf/httpd.conf <<EOF
<FilesMatch \.php$>
    SetHandler application/x-httpd-php
</FilesMatch>
EOF
sed -i "s/.*DirectoryIndex index.html/  DirectoryIndex index.php index.html/g" /usr/local/apache/conf/httpd.conf

#配置php.ini文件
sed -i "s/;date.timezone =/date.timezone = Asia\/Shanghai/g" /usr/local/php/etc/php.ini
sed -i "s/post_max_size =.*/post_max_size = 50M/g" /usr/local/php/etc/php.ini
sed -i "s/upload_max_filesize =.*/upload_max_filesize = 50M/g" /usr/local/php/etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /usr/local/php/etc/php.ini

#启动Apache
service httpd start

#下载探针
wget -O /usr/local/apache/htdocs/tz.zip http://www.yahei.net/tz/tz.zip
cd /usr/local/apache/htdocs/
unzip tz.zip
rm -rf /usr/local/apache/htdocs/tz.zip

#下载phpMyAdmin
wget -O /usr/local/apache/htdocs/phpmyadmin.tar.gz http://sourceforge.net/projects/phpmyadmin/files/phpMyAdmin/4.3.12/phpMyAdmin-4.3.12-all-languages.tar.gz/download
tar -zxf /usr/local/apache/htdocs/phpmyadmin.tar.gz -C /usr/local/apache/htdocs/
mv /usr/local/apache/htdocs/phpMyAdmin-* /usr/local/apache/htdocs/phpmyadmin
rm -rf /usr/local/apache/htdocs/phpmyadmin.tar.gz

#询问是否删除源文件
read -p "Do you want to delete all the source files downloaded in ~/.lanmp/resources?[Y/N]" delsource
if [ "$delsource" = "Y" ] || [ "$delsource" = "y" ]; then
	echo "Deleting,please wait..."
	rm -rf ~/.lanmp/resources/libmcrypt*
	rm -rf ~/.lanmp/resources/mcrypt*
	rm -rf ~/.lanmp/resources/mhash*
	rm -rf ~/.lanmp/resources/pcre*
	rm -rf ~/.lanmp/resources/mariadb*
	rm -rf ~/.lanmp/resources/php*
	rm -rf ~/.lanmp/resources/httpd*
	rm -rf ~/.lanmp/resources/apr*
else
    echo "Installation finished without delete resource files."
fi


echo "========================================================================="
echo "Centos + Apache + MariaDB + PHP 环境已安装完成，您可以用以下命令进行管理"
echo "Apache:    service httpd {start|stop|restart}"
echo "MariaDB:   service mysqld {start|stop|restart}"
echo "访问http://您的网址/tz.php可以访问PHP探针"
echo "访问http://您的网址/phpmyadmin可以访问phpmyadmin"
echo "Script Written by Junorz.com"
echo "========================================================================="

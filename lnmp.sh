#!/bin/bash
#====================================================================
# Centos + Nginx + MariaDB + PHP Auto Install Script
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
rm -rf ~/.lanmp/resources/nginx.conf

#================================准备安装工作==================================
#
#尝试下载nginx配置文件
wget -O ~/.lanmp/resources/nginx.conf http://source.ocha.so/nginx.conf
if [ $? -ne 0 ]; then
	echo "The configure file of nginx cannot be downloaded. Please check if http://source.ocha.so/ can be accessed or not."
	exit 1
else
	echo "Installaion will begin..."
fi


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
echo "MariaDB root password will be set to:$rootpwd"
echo "=================================================="

#自定义Nginx版本
#版本号参照http://nginx.org/en/download.html
echo "The version of Nginx can be referenced to http://nginx.org/en/download.html"
read -p "Enter the version you want to install(1.6.2 by deafult):" vernginx
if [ "$vernginx" = "" ]; then
	vernginx="1.6.2"
fi
read -p "Do you want to install Nginx $vernginx?[Y/N]" ifinstall
if [ "$ifinstall" = "Y" ] || [ "$ifinstall" = "y" ]; then
	echo "================================"
	echo "Nginx$vernginx will be installed"
	echo "Trying downloading the Nginx..."
	echo "================================"
	#尝试获取自定义的Nginx版本，若不成功，则退出
	wget -O ~/.lanmp/resources/nginx.tar.gz http://nginx.org/download/nginx-$vernginx.tar.gz
	if [ $? -ne 0 ]; then
		echo "Nginx $vernginx cannot be downloaded.Please check if you have enter a correct version."
		exit 1
	else
		echo "Nginx download succeed.Will continue to install the Pre-install Environment."
	fi
else
	echo "Installation interrupted.Try to run this script again."
	exit 1
fi

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
cd ~/.lanmp/resources
wget -O pcre.tar.gz http://sourceforge.net/projects/lanmp/files/pcre-8.36.tar.gz/download
tar -zxf pcre.tar.gz
cd ~/.lanmp/resources/pcre*
./configure
make && make install

#================================安装Nginx==================================
#创建运行Nginx进程的用户
groupadd www
useradd -M -s /sbin/nologin -g www www

#避免系统找不到PCRE等库
export LD_LIBRARY_PATH=/usr/local/lib

cd ~/.lanmp/resources
tar -zxf nginx.tar.gz
cd ~/.lanmp/resources/nginx*
./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-ipv6
make && make install

#软链接以便命令行直接调用
ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx

#启动Nginx请直接在命令行输入nginx
#停止Nginx请直接在命令行输入nginx -s stop
#重新载入nginx.conf请直接在命令行输入nginx -s reload

#加入开机自启动，如果不需要自在/etc/rc.d/rc.local文件里删除相应命令
echo "/usr/bin/nginx" >> /etc/rc.d/rc.local

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
cd ~/.lanmp/resources/php*
./configure --prefix=/usr/local/php \
--with-config-file-path=/usr/local/php/etc \
--enable-fpm \
--with-fpm-user=www \
--with-fpm-group=www \
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
cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
cp sapi/fpm/php-fpm /usr/local/bin

#软链接以便命令行直接调用
ln -s /usr/local/bin/php-fpm /usr/bin/php-fpm

#启动php-fpm请直接在命令行输入php-fpm
#停止php-fpm请直接在命令行输入pkill php-fpm

#加入开机自启动，如果不需要自在/etc/rc.d/rc.local文件里删除相应命令
echo "/usr/bin/php-fpm" >> /etc/rc.d/rc.local

#配置php.ini文件
sed -i "s/^.*cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/g" /usr/local/php/etc/php.ini
sed -i "s/;date.timezone =/date.timezone = Asia\/Shanghai/g" /usr/local/php/etc/php.ini
sed -i "s/post_max_size =.*/post_max_size = 50M/g" /usr/local/php/etc/php.ini
sed -i "s/upload_max_filesize =.*/upload_max_filesize = 50M/g" /usr/local/php/etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /usr/local/php/etc/php.ini

#替换Nginx.conf文件以便支持PHP文件
mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx-backup.conf
cp ~/.lanmp/resources/nginx.conf /usr/local/nginx/conf/nginx.conf

#启动nginx
/usr/bin/nginx

#启动php-fpm进程
/usr/bin/php-fpm

#下载探针
wget -O /usr/local/nginx/html/tz.zip http://www.yahei.net/tz/tz.zip
cd /usr/local/nginx/html/
unzip tz.zip
rm -rf /usr/local/nginx/html/tz.zip

#下载phpMyAdmin
wget -O /usr/local/nginx/html/phpmyadmin.tar.gz http://sourceforge.net/projects/phpmyadmin/files/phpMyAdmin/4.4.1.1/phpMyAdmin-4.4.1.1-all-languages.tar.gz/download
tar -zxf /usr/local/nginx/html/phpmyadmin.tar.gz -C /usr/local/nginx/html/
mv /usr/local/nginx/html/phpMyAdmin-* /usr/local/nginx/html/phpmyadmin
rm -rf /usr/local/nginx/html/phpmyadmin.tar.gz

#询问是否删除源文件
read -p "Do you want to delete all the source files downloaded in ~/.lanmp/resources?[Y/N]" delsource
if [ "$delsource" = "Y" ] || [ "$delsource" = "y" ]; then
	echo "Deleting,please wait..."
	rm -rf ~/.lanmp/resources/libmcrypt*
	rm -rf ~/.lanmp/resources/mcrypt*
	rm -rf ~/.lanmp/resources/mhash*
	rm -rf ~/.lanmp/resources/pcre*
	rm -rf ~/.lanmp/resources/nginx*
	rm -rf ~/.lanmp/resources/mariadb*
	rm -rf ~/.lanmp/resources/php*
    rm -rf ~/.lanmp/resources/nginx.conf
else
    echo "Installation finished without delete resource files."
fi

echo "========================================================================="
echo "Centos + Nginx + MariaDB + PHP 环境已安装完成，您可以用以下命令进行管理"
echo "Nginx:    启动：nginx|重载：nginx -s reload|停止：nginx -s stop"
echo "PHP-FPM:  启动：php-fpm|停止：pkill php-fpm"
echo "MariaDB:  service mysqld {start|stop|restart}"
echo "访问http://您的网址/tz.php可以访问PHP探针"
echo "访问http://您的网址/phpmyadmin可以访问phpmyadmin"
echo "Script Written by Junorz.com"
echo "========================================================================="

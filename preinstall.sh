#!/bin/bash
#Welcome http://www.junorz.com

# 检查是否为管理员
if [ $(id -u) != "0" ]; then
    echo "Please login as root to run this script"
    exit 1
fi

#通过Yum安装编译环境
yum -y groupinstall "Development Tools"
yum -y install wget unzip libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel curl curl-devel libtool libtool-ltdl-devel openssl-devel ncurses ncurses-devel

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
cd /root
wget http://source.ocha.so/libmcrypt-2.5.8.tar.gz
wget http://source.ocha.so/mcrypt-2.6.8.tar.gz
wget http://source.ocha.so/mhash-0.9.9.9.tar.gz
tar -zxf libmcrypt-2.5.8.tar.gz
tar -zxf mcrypt-2.6.8.tar.gz
tar -zxf mhash-0.9.9.9.tar.gz
cd /root/libmcrypt-2.5.8
./configure
make && make install
cd /root/mhash-0.9.9.9
./configure
make && make install
cd /root/mcrypt-2.6.8
./configure
make && make install

#安装bison
yum -y remove bison*
cd /root
wget http://source.ocha.so/bison.tar.gz
tar -zxf bison.tar.gz
cd /root/bison*
./configure
make && make install

#安装pcre
cd /root
wget http://source.ocha.so/pcre.tar.gz
tar -zxf pcre.tar.gz
cd /root/pcre*
./configure
make && make install

#安装CMake
cd /root
wget http://source.ocha.so/cmake.tar.gz
tar -zxf cmake.tar.gz
cd /root/cmake*
./bootstrap
make && make install

#安装APR
cd /root
wget http://source.ocha.so/apr.tar.gz
tar -zxf apr*
cd apr*
./configure --prefix=/usr/local/apr
make && make install

#安装APR-util
cd /root
wget http://source.ocha.so/apr-util.tar.gz
tar -zxf apr-util*
cd apr-util*
./configure --prefix=/usr/local/apr-util -with-apr=/usr/local/apr/bin/apr-1-config
make && make install

#更新系统库路径
echo "/usr/local/apr/lib" >> /etc/ld.so.conf
echo "/usr/local/apr-util/lib" >> /etc/ld.so.conf
ldconfig

cd /root

#下载其它安装脚本
read -p "Would you want to download other scripts?[Y/N]" ifdownload
if [ "$ifdownload" = "Y" ] || [ "$ifdownload" = "y" ];then
	echo "Downloading..."
	cd /root
	wget http://source.ocha.so/nginx.sh
	chmod +x nginx.sh
	wget http://source.ocha.so/apache.sh
	chmod +x apache.sh
	wget http://source.ocha.so/mariadb.sh
	chmod +x mariadb.sh
	wget http://source.ocha.so/php-nginx.sh
	chmod +x php-nginx.sh
	wget http://source.ocha.so/php-apache.sh
	chmod +x php-apache.sh
else
	echo "Quit without downloading..."
fi

echo "========================================================================="
echo "编译环境已安装完成，请运行其他安装脚本 Script Written by Junorz.com"
echo "========================================================================="

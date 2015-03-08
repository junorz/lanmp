#!/bin/bash
#Welcome http://www.junorz.com

# 检查是否为管理员
if [ $(id -u) != "0" ]; then
    echo "Please login as root to run this script"
    exit 1
fi

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
cd /root
wget -O libmcrypt.tar.gz  http://sourceforge.net/projects/lanmp/files/libmcrypt-2.5.8.tar.gz/download
wget -O mcrypt.tar.gz http://sourceforge.net/projects/lanmp/files/mcrypt-2.6.8.tar.gz/download
wget -O mhash.tar.gz http://sourceforge.net/projects/lanmp/files/mhash-0.9.9.9.tar.gz/download
tar -zxf libmcrypt.tar.gz
tar -zxf mcrypt.tar.gz
tar -zxf mhash.tar.gz
cd /root/libmcrypt*
./configure
make && make install
cd /root/mhash*
./configure
make && make install
cd /root/mcrypt*
./configure
make && make install

#安装bison
yum -y remove bison*
cd /root
wget -O bison.tar.gz http://sourceforge.net/projects/lanmp/files/bison-3.0.4.tar.gz/download
tar -zxf bison.tar.gz
cd /root/bison*
./configure
make && make install

#安装pcre
cd /root
wget -O pcre.tar.gz http://sourceforge.net/projects/lanmp/files/pcre-8.36.tar.gz/download
tar -zxf pcre.tar.gz
cd /root/pcre*
./configure
make && make install

#安装CMake
cd /root
wget -O cmake.tar.gz http://sourceforge.net/projects/lanmp/files/cmake-3.2.0-rc2.tar.gz/download
tar -zxf cmake.tar.gz
cd /root/cmake*
./bootstrap
make && make install

#安装APR
cd /root
wget -O apr.tar.gz http://sourceforge.net/projects/lanmp/files/apr-1.5.1.tar.gz/download
tar -zxf apr.tar.gz
cd apr*
./configure --prefix=/usr/local/apr
make && make install

#安装APR-util
cd /root
wget -O apr-util.tar.gz http://sourceforge.net/projects/lanmp/files/apr-util-1.5.4.tar.gz/download
tar -zxf apr-util.tar.gz
cd apr-util*
./configure --prefix=/usr/local/apr-util -with-apr=/usr/local/apr/bin/apr-1-config
make && make install

#更新系统库路径
echo "/usr/local/apr/lib" >> /etc/ld.so.conf
echo "/usr/local/apr-util/lib" >> /etc/ld.so.conf
ldconfig

echo "==========================================="
echo "脚本已运行完成 Script Written by Junorz.com"
echo "==========================================="

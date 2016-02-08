#!/bin/bash
#========================================================================================
# Functions for LNMP/LAMP Auto Install Script
#
# Copyright (c) 2011-2015 Junorz.com All rights reserved.
#
# Intro: http://www.junorz.com/archives/374.html
#
#========================================================================================

#================================Start-编译环境安装函数-Start===============================
Preinstall(){
#安装编译环境，然后移除自带软件
if [ "$PM" = "yum" ]; then
    #安装编译环境
    yum -y install epel-release
    yum -y groupinstall "Development Tools"
    yum -y install gcc-c++ wget unzip bison libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel curl curl-devel libtool libtool-ltdl-devel openssl-devel ncurses ncurses-devel libaio-devel cyrus-sasl-devel jemalloc chkconfig
    #删除预安装项
    yum -y remove mysql-server mysql mysql-libs
    yum -y remove php-mysql
    yum -y remove httpd*
    yum -y remove php*
    yum -y remove httpd
    rm -rf /etc/my.cnf
    rm -rf /usr/lib/mysql
    rm -rf /usr/share/mysql

elif [ "$PM" = "apt" ]; then
    #安装编译环境（Debian编译环境参考自lnmp.org）
    apt-get update -y
    apt-get autoremove -y
    apt-get -fy install
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y build-essential gcc g++ make
    for packages in build-essential gcc g++ make cmake autoconf automake re2c wget cron bzip2 libzip-dev libc6-dev file rcconf flex vim bison m4 gawk less cpp binutils diffutils unzip tar bzip2 libbz2-dev libncurses5 libncurses5-dev libtool libevent-dev openssl libssl-dev zlibc libsasl2-dev libltdl3-dev libltdl-dev zlib1g zlib1g-dev libbz2-1.0 libbz2-dev libglib2.0-0 libglib2.0-dev libpng3 libjpeg62 libjpeg62-dev libjpeg-dev libpng-dev libpng12-0 libpng12-dev libkrb5-dev curl libcurl3 libcurl3-gnutls libcurl4-gnutls-dev libcurl4-openssl-dev libpq-dev libpq5 gettext libjpeg-dev libpng12-dev libxml2-dev libcap-dev ca-certificates debian-keyring debian-archive-keyring libc-client2007e-dev psmisc patch git libc-ares-dev libicu-dev e2fsprogs libxslt libxslt1-dev libjemalloc-dev libaio-dev libfreetype6-dev;
    do apt-get install -y $packages --force-yes; done
    #删除预安装项
    apt-get update -y
    for removepackages in apache2 apache2-doc apache2-utils apache2.2-common apache2.2-bin apache2-mpm-prefork apache2-doc apache2-mpm-worker mysql-client mysql-server mysql-common mysql-server-core-5.5 mysql-client-5.5 php5 php5-common php5-cgi php5-cli php5-mysql php5-curl php5-gd;
    do apt-get purge -y $removepackages; done
    killall apache2
    dpkg -l |grep apache
    dpkg -P apache2 apache2-doc apache2-mpm-prefork apache2-utils apache2.2-common
    dpkg -l |grep mysql
    dpkg -P mysql-server mysql-common libmysqlclient15off libmysqlclient15-dev
    dpkg -l |grep php
    dpkg -P php5 php5-common php5-cli php5-cgi php5-mysql php5-curl php5-gd
    apt-get autoremove -y && apt-get clean
fi


#添加系统库路径
echo "/usr/local/lib" >> /etc/ld.so.conf
ldconfig


#安装Libmcrypt,mhash,mcrypt
cd ~/.lanmp/resources
#判断是否已经存在源文件
if [ ! -f ~/.lanmp/resources/libmcrypt.tar.gz ]; then
  wget -O libmcrypt.tar.gz  $libmcrypturl
fi
tar -zxf libmcrypt.tar.gz
cd ~/.lanmp/resources/libmcrypt*
./configure
make && make install
cd ~/.lanmp/resources/libltdl/
./configure --enable-ltdl-install
make && make install
ldconfig

if [ ! -f ~/.lanmp/resources/mcrypt.tar.gz ]; then
  wget -O mcrypt.tar.gz $mcrypturl
fi
tar -zxf mcrypt.tar.gz
cd ~/.lanmp/resources/mhash*
./configure
make && make install
ldconfig

if [ ! -f ~/.lanmp/resources/mhash.tar.gz ]; then
  wget -O mhash.tar.gz $mhashurl
fi
tar -zxf mhash.tar.gz
cd ~/.lanmp/resources/mcrypt*
./configure
make && make install
ldconfig

#安装pcre
cd ~/.lanmp/resources
if [ ! -f ~/.lanmp/resources/pcre.tar.gz ]; then
  wget -O pcre.tar.gz $pcreurl
fi
tar -zxf pcre.tar.gz
cd ~/.lanmp/resources/pcre*
./configure
make && make install

#安装CMake
cd ~/.lanmp/resources
if [ ! -f ~/.lanmp/resources/cmake.tar.gz ]; then
  wget -O cmake.tar.gz $cmakeurl
fi
tar -zxf cmake.tar.gz
cd ~/.lanmp/resources/cmake*
./bootstrap
make && make install

#安装APR
cd ~/.lanmp/resources
if [ ! -f ~/.lanmp/resources/apr.tar.gz ]; then
  wget -O apr.tar.gz $aprurl
fi
tar -zxf apr.tar.gz
cd apr*
./configure --prefix=/usr/local/apr
make && make install

#安装APR-util
cd ~/.lanmp/resources
if [ ! -f ~/.lanmp/resources/apr-util.tar.gz ]; then
  wget -O apr-util.tar.gz $aprutil_url
fi
tar -zxf apr-util.tar.gz
cd apr-util*
./configure --prefix=/usr/local/apr-util -with-apr=/usr/local/apr/bin/apr-1-config
make && make install

#更新系统库路径
echo "/usr/local/apr/lib" >> /etc/ld.so.conf
echo "/usr/local/apr-util/lib" >> /etc/ld.so.conf
ldconfig

}
#================================End-编译环境安装函数-End===============================

#=====================Start-确认安装程序版本、密码相关初始化函数-Start======================
#------询问要安装的Nginx版本------
#版本号参照http://nginx.org/en/download.html
Nginx_Version(){
#判断是否已经存在源文件
if [ ! -f ~/.lanmp/resources/nginx.tar.gz ]; then
  echo "The version of Nginx can be referenced to http://nginx.org/en/download.html"
  read -p "Enter the version you want to install(1.8.1 by deafult):" vernginx
  if [ "$vernginx" = "" ]; then
	   vernginx="1.8.1"
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
    exit 1
  fi

fi
}

#------询问MariaDB的Root密码------
MariaDB_RootPassword(){
read -p "Enter a password for MariaDB root:" rootpwd
if [ "$rootpwd" = "" ]; then
	rootpwd="root"
fi
echo "=================================================="
echo "MariaDB root password will be set to:$rootpwd"
echo "=================================================="
}

#------询问要安装的MariaDB版本------
MariaDB_Version(){
#判断是否已经存在源文件
if [ ! -f ~/.lanmp/resources/mariadbin.tar.gz ]; then
  #下载二进制安装包
  if [ "$sysbit" = "32" ]; then
  	ldd --version
  	read -p "Is the version of glibc showed above over 2.14+?[Y/N]" verglibc
  	if [ "$verglibc" = "Y" ] || [ "$verglibc" = "y" ]; then
  		wget -O ~/.lanmp/resources/mariadbin.tar.gz $mariadb_bin_glibc214_32_url
  	elif [ "$verglibc" = "N" ] || [ "$verglibc" = "n" ]; then
  		wget -O ~/.lanmp/resources/mariadbin.tar.gz $mariadb_bin_32_url
  	else
  		echo "Please enter Y or N.Try to run this script again."
  		exit 1
  	fi
  elif [ "$sysbit" = "64" ]; then
  	ldd --version
  	read -p "Is the version of glibc showed above over 2.14+?[Y/N]" verglibc
  	if [ "$verglibc" = "Y" ] || [ "$verglibc" = "y" ]; then
  		wget -O ~/.lanmp/resources/mariadbin.tar.gz $mariadb_bin_glicb214_64_url
  	elif [ "$verglibc" = "N" ] || [ "$verglibc" = "n" ]; then
  		wget -O ~/.lanmp/resources/mariadbin.tar.gz $mariadb_bin_64_url
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
#=====================End-确认安装程序版本、密码相关初始化函数-End======================

#===============================Start-程序安装函数-Start============================
#-------Nginx安装函数------
Install_Nginx(){

	#创建运行Nginx进程的用户
	groupadd www
	useradd -M -s /sbin/nologin -g www www

	#避免系统找不到PCRE等库
	export LD_LIBRARY_PATH=/usr/local/lib

	#开始编译
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

#加入开机自启动
cp ~/.lanmp/includes/init.nginx /etc/init.d/nginx
chmod +x /etc/init.d/nginx
if [ "$PM" = "yum" ]; then
    chkconfig --add nginx
    chkconfig nginx on
elif [ "$PM" = "apt" ]; then
    update-rc.d -f nginx defaults
fi

#启动Nginx
service nginx start
}



#------Apache安装函数------
Install_Apache(){
#创建运行Apache的用户
groupadd www
useradd -M -s /sbin/nologin -g www www

#下载编译
cd ~/.lanmp/resources

#判断是否已经存在源文件
if [ ! -f ~/.lanmp/resources/httpd.tar.gz ]; then
  wget -O httpd.tar.gz  $apacheurl
fi

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

#添加服务
cp ~/.lanmp/includes/init.httpd /etc/init.d/httpd
chmod +x /etc/init.d/httpd
if [ "$PM" = "yum" ]; then
    chkconfig --add httpd
    chkconfig httpd on
elif [ "$PM" = "apt" ]; then
    update-rc.d -f httpd defaults
fi
service httpd start

}



#------MariaDB二进制版本安装函数------
Install_MariaDBin(){
#解压到相应目录
echo "Extracting Mariadbin.tar.gz....."
tar -zxf ~/.lanmp/resources/mariadbin.tar.gz -C /usr/local
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
chmod +x /etc/init.d/mysqld
if [ "$PM" = "yum" ]; then
    chkconfig --add mysqld
    chkconfig mysqld on
elif [ "$PM" = "apt" ]; then
    update-rc.d -f mysqld defaults
fi

#设置系统库路径
echo "/usr/local/mysql/lib" >> /etc/ld.so.conf
ldconfig

#启动服务
service mysqld start

#设置管理员密码
/usr/local/mysql/bin/mysqladmin -u root password $rootpwd
}


#------MariaDB源码编译版本函数------
Install_MairaDB(){
#创建运行Mariadb进程的用户
groupadd mysql
useradd -r -g mysql mysql

#下载编译
cd ~/.lanmp/resources

#判断是否已经存在源文件
if [ ! -f ~/.lanmp/resources/mariadb.tar.gz ]; then
  wget -O mariadb.tar.gz $mariadb_source_url
fi

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
chmod +x /etc/init.d/mysqld
if [ "$PM" = "yum" ]; then
    chkconfig --add mysqld
    chkconfig mysqld on
elif [ "$PM" = "apt" ]; then
    update-rc.d -f mysqld defaults
fi

#设置系统库路径
echo "/usr/local/mysql/lib" >> /etc/ld.so.conf
ldconfig

#启动服务
service mysqld start

#设置管理员密码
/usr/local/mysql/bin/mysqladmin -u root password $rootpwd
}


#------基于Nginx的PHP安装函数------
Install_PHPwithNginx(){

#下载编译
cd ~/.lanmp/resources

#判断是否已经存在源文件
if [ ! -f ~/.lanmp/resources/php.tar.gz ]; then
	wget -O php.tar.gz $phpurl
fi

tar -zxf php.tar.gz
cd php*
./configure --prefix=/usr/local/php \
--with-config-file-path=/usr/local/php/etc \
--enable-fpm \
--with-fpm-user=www \
--with-fpm-group=www \
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
cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf
cp sapi/fpm/php-fpm /usr/bin

#使php-fpm产生pid文件
sed -i "s/;pid = run\/php-fpm.pid/pid = run\/php-fpm.pid/g" /usr/local/php/etc/php-fpm.conf

#加入开机自启动
cp ~/.lanmp/includes/init.phpfpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm
if [ "$PM" = "yum" ]; then
    chkconfig --add php-fpm
    chkconfig php-fpm on
elif [ "$PM" = "apt" ]; then
    update-rc.d -f php-fpm defaults
fi

#配置php.ini文件
sed -i "s/cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /usr/local/php/etc/php.ini
sed -i "s/;date.timezone =/date.timezone = Asia\/Shanghai/g" /usr/local/php/etc/php.ini
sed -i "s/post_max_size =.*/post_max_size = 50M/g" /usr/local/php/etc/php.ini
sed -i "s/upload_max_filesize =.*/upload_max_filesize = 50M/g" /usr/local/php/etc/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 300/g' /usr/local/php/etc/php.ini

#替换Nginx.conf文件以便支持PHP文件
mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx_backup.conf
cp ~/.lanmp/includes/nginx.conf /usr/local/nginx/conf/nginx.conf

#重启nginx
service nginx restart

#启动php-fpm进程
service php-fpm start

#下载探针
#目前PHP7没有好的探针，先保留
#wget -O /usr/local/nginx/html/tz.zip http://www.yahei.net/tz/tz.zip
#cd /usr/local/nginx/html/
#unzip tz.zip
#rm -rf /usr/local/nginx/html/tz.zip

#下载phpMyAdmin
wget -O /usr/local/nginx/html/phpmyadmin.tar.gz https://files.phpmyadmin.net/phpMyAdmin/4.5.4.1/phpMyAdmin-4.5.4.1-all-languages.zip
tar -zxf /usr/local/nginx/html/phpmyadmin.tar.gz -C /usr/local/nginx/html/
mv /usr/local/nginx/html/phpMyAdmin-* /usr/local/nginx/html/phpmyadmin
rm -rf /usr/local/nginx/html/phpmyadmin.tar.gz

}


#------基于Apache的PHP安装函数------
Install_PHPwithApache(){
#下载编译
cd ~/.lanmp/resources
#判断是否已经存在源文件
if [ ! -f ~/.lanmp/resources/php.tar.gz ]; then
  wget -O php.tar.gz $phpurl
fi
tar -zxf php.tar.gz
cd php*
./configure --prefix=/usr/local/php \
--with-config-file-path=/usr/local/php/etc \
--enable-fpm \
--with-fpm-user=www \
--with-fpm-group=www \
--with-apxs2=/usr/local/apache/bin/apxs \
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

#重启服务器
service httpd restart

#下载探针
#目前PHP7没有好的探针，先保留
#wget -O /usr/local/apache/htdocs/tz.zip http://www.yahei.net/tz/tz.zip
#cd /usr/local/apache/htdocs/
#unzip tz.zip
#rm -rf /usr/local/apache/htdocs/tz.zip

#下载phpMyAdmin
wget -O /usr/local/apache/htdocs/phpmyadmin.tar.gz https://files.phpmyadmin.net/phpMyAdmin/4.5.4.1/phpMyAdmin-4.5.4.1-all-languages.zip
tar -zxf /usr/local/apache/htdocs/phpmyadmin.tar.gz -C /usr/local/apache/htdocs/
mv /usr/local/apache/htdocs/phpMyAdmin-* /usr/local/apache/htdocs/phpmyadmin
rm -rf /usr/local/apache/htdocs/phpmyadmin.tar.gz
}

#===============================End-程序安装函数-End================================

#===================================Start-其它函数-Start============================
#判断系统是32还是64位
#注：这条函数来自lnmp.org
Get_OS_Bit()
{
    if [[ `getconf WORD_BIT` = '32' && `getconf LONG_BIT` = '64' ]] ; then
        sysbit='64'
    else
        sysbit='32'
    fi
}

#判断系统类型
#注：这条函数来自lnmp.org
Get_Dist_Name()
{
    if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        DISTRO='CentOS'
        PM='yum'
    elif grep -Eqi "Red Hat Enterprise Linux Server" /etc/issue || grep -Eq "Red Hat Enterprise Linux Server" /etc/*-release; then
        DISTRO='RHEL'
        PM='yum'
    elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun" /etc/*-release; then
        DISTRO='Aliyun'
        PM='yum'
    elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release; then
        DISTRO='Fedora'
        PM='yum'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        DISTRO='Debian'
        PM='apt'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        DISTRO='Ubuntu'
        PM='apt'
    elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release; then
        DISTRO='Raspbian'
        PM='apt'
    else
        DISTRO='unknow'
    fi
    Get_OS_Bit
}

StartInstallation(){
  echo "Installation is ready. Press Enter to start the installation."
  read -p "Or Press Ctrl+C to exit."
}
#===================================End-其它函数-End============================

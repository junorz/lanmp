#!/bin/bash
#====================================================================
# Apache Auto Install Script
#
# Copyright (c) 2011-2015 Junorz.com All rights reserved.
#
# Intro: http://www.junorz.com/archives/374.html
#
#====================================================================

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
cp ~/.lanmp/includes/Starupscrupt_nginx /etc/init.d/nginx
if [ "$PM" = "yum" ]; then
    chkconfig --add nginx
    chkconfig nginx on
elif [ "$PM" = "apt" ]; then
    update-rc.d -f nginx defaults
fi

#启动Nginx
/usr/bin/nginx
}

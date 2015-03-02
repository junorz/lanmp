#!/bin/bash
#Welcome http://www.junorz.com

# 检查是否为管理员
if [ $(id -u) != "0" ]; then
    echo "Please login as root to run this script"
    exit 1
fi

#创建运行Nginx进程的用户
groupadd www
useradd -s /sbin/nologin -g www www

#避免系统找不到PCRE等库
export LD_LIBRARY_PATH=/usr/local/lib

cd /root
wget http://nginx.org/download/nginx-1.6.2.tar.gz
tar -zxf nginx-1.6.2.tar.gz
cd /root/nginx-1.6.2
./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --with-ipv6
make && make install

#软链接以便命令行直接调用
ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx

#启动Nginx请直接在命令行输入nginx
#停止Nginx请直接在命令行输入nginx -s stop
#重新载入nginx.conf请直接在命令行输入nginx -s reload

#加入开机自启动，如果不需要自在/etc/rc.d/rc.local文件里删除相应命令
echo "/usr/bin/nginx" >> /etc/rc.d/rc.local

#启动Nginx
/usr/bin/nginx

cd /root

echo "========================================================================="
echo "Nginx已安装完成，请运行其他安装脚本 Script Written by Junorz.com"
echo "========================================================================="

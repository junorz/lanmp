<h1>简介</h1>
<ol>
<li>此脚本采用分步安装的方式可以在采用Centos服务器的系统上上快速布署WEB环境。</li>
<li>已在<code>Centos6</code>/<code>Centos7</code>的32和64位系统下测试完成。</li>
<li>目前可以布署的组合有<code>Nginx</code>+<code>MariaDB</code>+<code>PHP</code>或<code>Apache</code>+<code>MariaDB</code>+<code>PHP</code></li>
<li>分步安装可以避免一键包中途产生错误需要重头再来的问题。</li>
</ol>

<h1>一键包安装使用教程</h1>
<p>1.下载脚本文件</p>
<pre><code>
yum -y install wget unzip
cd /root
wget -O lanmp.zip https://github.com/junorz/lanmp/archive/master.zip
unzip lanmp.zip
cd lanmp-master
chmod -R +x *.sh
</code></pre>

<p>2.选择搭建环境</p>
<p>目前可以布署的组合有<code>Nginx</code>+<code>MariaDB</code>+<code>PHP</code>或<code>Apache</code>+<code>MariaDB</code>+<code>PHP</code></p>
<p>安装<code>Nginx</code>+<code>MariaDB</code>+<code>PHP</code></p>
<pre><code>
bash lnmp.sh
</code></pre>
<p>安装<code>Apache</code>+<code>MariaDB</code>+<code>PHP</code></p>
<pre><code>
bash lamp.sh
</code></pre>
<p>根据屏幕上的提示完成安装即可</p>

<h1>以下为分步安装教程</h1>
<p>1.下载脚本文件</p>
<pre><code>
yum -y install wget unzip
cd /root
wget -O lanmp.zip https://github.com/junorz/lanmp/archive/master.zip
unzip lanmp.zip
cd lanmp-master
chmod -R +x *.sh
</code></pre>

<p>2.安装编译环境</p>
<pre><code>
bash parts/preinstall.sh
</code></pre>

<h1>搭建Nginx+MariaDB+PHP环境</h1>
<p>因为PHP需要在编译时指定MariaDB相关文件位置，需要最后安装。</p>
<p>Nginx/MariaDB安装顺序随意。</p>
<p>1.安装<code>Nginx</code></p>
<pre><code>
bash parts/nginx.sh
</code></pre>
<p>运行后会询问您要安装的Nginx版本，请参照<a href=http://nginx.org/en/download.html>Nginx下载页面</a>输入版本号（如1.6.2）。</p>
<p>如果直接回车则安装1.6.2版本。</p>

<p>2.安装<code>MariaDB</code></p>
<p>MariaDB分为使用<code>二进制包</code>（推荐）和<code>源码编译</code>安装。小内存服务器慎用源代码安装，可能会因为内存不够编译失败。</p>
<p>使用二进制包安装，请运行以下命令：</p>
<pre><code>
bash parts/mariadb-bin.sh
</code></pre>
<p>运行后会询问您是32位系统还是64位系统，GLIBC是否为2.14版本以上，按照提示输入即可。</p>
<p>使用源码编译安装，请运行以下命令：</p>
<pre><code>
bash parts/mariadb.sh
</code></pre>
<p>安装完成后会提示您输入root密码，如果回车则默认密码为root。</p>

<p>3.安装<code>PHP</code></p>
<pre><code>
bash parts/php-nginx.sh
</code></pre>

<h1>搭建Apache+MariaDB+PHP环境</h1>
<p>因为PHP需要在编译时指定Apache及MariaDB相关文件位置，需要最后安装。</p>
<p>Apache/MariaDB安装顺序随意。</p>
<p>1.安装<code>Apache</code></p>
<pre><code>
bash parts/apache.sh
</code></pre>

<p>2.安装<code>MariaDB</code></p>
<p>MariaDB分为使用<code>二进制包</code>（推荐）和<code>源码编译</code>安装。小内存服务器慎用源代码安装，可能会因为内存不够编译失败。</p>
<p>〇使用二进制包安装，请运行以下命令：</p>
<pre><code>
bash parts/mariadb-bin.sh
</code></pre>
<p>运行后会询问您是32位系统还是64位系统，GLIBC是否为2.14版本以上，按照提示输入即可。</p>
<p>〇使用源码编译安装，请运行以下命令：</p>
<pre><code>
bash parts/mariadb.sh
</code></pre>
<p>安装完成后会提示您输入root密码，如果回车则默认密码为root。</p>

<p>3.安装<code>PHP</code></p>
<pre><code>
bash parts/php-apache.sh
</code></pre>

<h1>卸载</h1>
运行uninstall.sh即可。
<pre><code>
bash uninstall.sh
</code></pre>

<h1>一、简介</h1>
<ol>
<li>此脚本所编译或安装的程序版本为：<h4>Nginx 1.8.0  /  Apache 2.4.17  +  MariaDB 10.1.9  + PHP 7</h4>
其中Nginx默认安装目前的Stable版本，但在安装过程中脚本会引导问询是否安装最新Mainline版本。</li>
<li>此脚本采用一键/分步安装的方式可以在采用Centos/Debian/Ubuntu服务器的系统上快速布署WEB环境。</li>
<li>已在<code>Centos6</code>/<code>Centos7</code>的32和64位系统下测试完成。</li>
<li>目前可以布署的组合有<code>Nginx</code>+<code>MariaDB</code>+<code>PHP</code>或<code>Apache</code>+<code>MariaDB</code>+<code>PHP</code></li>
<li>请不要把Nginx和Apahce一起安装！</li>
<li>分步安装可以避免一键包中途产生错误需要重头再来的问题。</li>
</ol>

<h1>二、如何使用git命令同步到本地</h1>
<pre><code>
git clone https://github.com/junorz/lanmp.git ~/.lanmp
</code></pre>
<h4>注意：一定不能同步到 ~/.lanmp 以外的地方！！</h4>

<h1>三、如何更新到最新脚本</h1>
<pre><code>cd ~/.lanmp
git pull</code></pre>

<h1>四、安装方法</h1>
<p>只需要给install.sh文件传递参数即可。例如：</p>
<pre><code>
install.sh lnmp
</code></pre>
<p>这样会一键安装lnmp。</p>
<p>可用的参数有：</p>
<pre><code>
lnmp          安装LNMP
lamp          安装LAMP
pre           安装编译环境（即：包含CMake,APR的编译环境，适合Apache和编译版本的Mariadb选用）
premin        最小安装编译环境（即：不包含CMake,APR的编译环境，适合Nginx和二进制版本Mariadb选用）
nginx         安装Nginx
apache        安装Apache
mariadb       编译安装Mariadb
mariadbin     安装二进制版本的Mariadb
phpnginx      在Nginx之上安装PHP
phpapache     在Apache之上安装PHP
</code></pre>
<p>下面有一些更为具体的安装实例：</p>

<h1>五、一键安装实例</h1>
<h3>5.1 下载脚本文件</h3>
<pre><code>
yum -y install git wget
git clone https://github.com/junorz/lanmp.git ~/.lanmp
chmod -R +x ~/.lanmp
</code></pre>

<h3>5.2 选择搭建环境</h3>
<p>目前可以布署的组合有<code>Nginx</code>+<code>MariaDB</code>+<code>PHP</code>或<code>Apache</code>+<code>MariaDB</code>+<code>PHP</code></p>
<p>安装<code>Nginx</code>+<code>MariaDB</code>+<code>PHP</code></p>
<pre><code>
bash ~/.lanmp/install.sh lnmp
</code></pre>
<p>安装<code>Apache</code>+<code>MariaDB</code>+<code>PHP</code></p>
<pre><code>
bash ~/.lanmp/install.sh lamp
</code></pre>
<p>根据屏幕上的提示完成安装即可</p>

<h1>六、分步安装实列</h1>
<h3>6.1 下载脚本文件</h3>
<pre><code>
yum -y install git
git clone https://github.com/junorz/lanmp.git ~/.lanmp
chmod -R +x ~/.lanmp
</code></pre>

<h3>6.2 安装编译环境</h3>
<li>如果你需要安装Apache，编译环境需要完整完装。</li>
<pre><code>
bash ~/.lanmp/install.sh pre
</code></pre>

<li>如果你需要安装Nginx，则不需要安装诸如APR等库，可以最小安装编译环境。</li>
<li>但是，如果你需要编译安装MariaDB，因为需要用到CMake，完整安装编译环境。</li>
<pre><code>
bash ~/.lanmp/install.sh premin
</code></pre>

<h3>6.3 根据需要选择组合</h3>
<p>可以根据自己的需求自定义组合安装生产环境，这里给出的是最常见的两种组合。</p>
<p>当然你也可以只安装Nginx或只安装Apache等等。</p>

<h4>6.3.1 搭建Nginx+MariaDB+PHP环境</h4>
<p>因为PHP需要在编译时指定MariaDB相关文件位置，需要最后安装。</p>
<p>Nginx/MariaDB安装顺序随意。</p>
<p>1.安装<code>Nginx</code></p>
<pre><code>
bash ~/.lanmp/install.sh nginx
</code></pre>
<p>运行后会询问您要安装的Nginx版本，请参照<a href=http://nginx.org/en/download.html>Nginx下载页面</a>输入版本号（如1.8.0）。</p>
<p>如果直接回车则安装最新稳定版本。</p>

<p>2.安装<code>MariaDB</code></p>
<p>MariaDB分为使用<code>二进制包</code>（推荐）和<code>源码编译</code>安装。小内存服务器慎用源代码安装，可能会因为内存不够编译失败。</p>
<p>安装之前会提示您输入root密码，如果回车则默认密码为root。</p>
<p>使用二进制包安装，请运行以下命令：</p>
<pre><code>
bash ~/.lanmp/install.sh mariadbin
</code></pre>
<p>运行后会询问您是32位系统还是64位系统，GLIBC是否为2.14版本以上，按照提示输入即可。</p>
<p>使用源码编译安装，请运行以下命令：</p>
<pre><code>
bash ~/.lanmp/install.sh mariadb
</code></pre>

<p>3.安装<code>PHP</code></p>
<pre><code>
bash ~/.lanmp/install.sh phpnginx
</code></pre>

<h4>6.3.2 搭建Apache+MariaDB+PHP环境</h4>
<p>因为PHP需要在编译时指定Apache及MariaDB相关文件位置，需要最后安装。</p>
<p>Apache/MariaDB安装顺序随意。</p>
<p>1.安装<code>Apache</code></p>
<pre><code>
bash ~/.lanmp/install.sh apache
</code></pre>

<p>2.安装<code>MariaDB</code></p>
<p>MariaDB分为使用<code>二进制包</code>（推荐）和<code>源码编译</code>安装。小内存服务器慎用源代码安装，可能会因为内存不够编译失败。</p>
<p>安装之前会提示您输入root密码，如果回车则默认密码为root。</p>
<p>使用二进制包安装，请运行以下命令：</p>
<pre><code>
bash ~/.lanmp/install.sh mariadbin
</code></pre>
<p>运行后会询问您是32位系统还是64位系统，GLIBC是否为2.14版本以上，按照提示输入即可。</p>
<p>使用源码编译安装，请运行以下命令：</p>
<pre><code>
bash ~/.lanmp/install.sh mariadb
</code></pre>

<p>3.安装<code>PHP</code></p>
<pre><code>
bash ~/.lanmp/install.sh phpapache
</code></pre>

<h1>七、卸载</h1>
运行uninstall.sh即可。
<pre><code>
bash ~/.lanmp/uninstall.sh
</code></pre>

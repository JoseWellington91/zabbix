#��װapr
# deps
yum -y install gcc gcc-c++ libtool openssl openssl-devel ncurses ncurses-devel libxml2 libxml2-devel bison libXpm libXpm-devel fontconfig-devel libtiff libtiff-devel curl curl-devel readline readline-devel bzip2 bzip2-devel sqlite sqlite-devel zlib zlib-devel libpng-devel gd-devel freetype-devel perl perl-devel perl-ExtUtils-Embed

#apr
tar jxvf apr-1.5.2.tar.bz2  && cd apr-1.5.2
sed -i '/$RM "$cfgfile"/ s/^/#/' configure
./configure --prefix=/usr/local/apr
 make && make install

#��װapr-util
tar jxvf apr-util-1.5.4.tar.bz2 && cd  apr-util-1.5.4
./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr/bin/apr-1-config
make && make install

#��װpcre
tar jxvf pcre-8.37.tar.bz2 && cd pcre-8.37
./configure --prefix=/usr/local/pcre
make && make install

#����openssl
tar zxvf openssl-1.0.2a.tar.gz
cd openssl-1.0.2a
./config shared zlib
make && make install
mv /usr/bin/openssl /usr/bin/openssl.OFF
mv /usr/include/openssl /usr/include/openssl.OFF
ln -s /usr/local/ssl/bin/openssl /usr/bin/openssl
ln -s /usr/local/ssl/include/openssl /usr/include/openssl

#��װapache
tar jxvf httpd-2.4.12.tar.bz2 && cd httpd-2.4.12
./configure --prefix=/usr/local/apache-2.4.12 --sysconfdir=/etc/httpd --with-apr=/usr/local/apr/bin/apr-1-config --with-apr-util=/usr/local/apr-util/bin/apu-1-config  --with-pcre=/usr/local/pcre/ --enable-so --enable-mods-shared=most --enable-rewirte  --enable-ssl=shared --with-ssl=/usr/local/ssl
make && make install

#re2c (for php)
tar zxvf re2c-0.14.3.tar.gz && cd re2c-0.14.3
./configure && make &&  make install

# libiconv (for php)
tar zxvf libiconv-1.14.tar.gz && cd libiconv-1.14
./configure --prefix=/usr && make && make install

# php (for iF.SVNADMIN)
tar jxvf php-5.3.29.tar.bz2 && cd php-5.3.29
 ./configure --prefix=/Data/app/php-5.3.29  --with-config-file-path=/Data/app/php-5.3.29/etc --with-apxs2=/Data/app/apache-2.4.12/bin/apxs --with-libxml-dir --with-iconv-dir --with-png-dir --with-jpeg-dir --with-zlib --with-gd  --with-freetype-dir  --enable-gd-native-ttf  --with-readline --with-curl --with-bz2 --enable-mysqlnd --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-openssl-dir --without-pear  --enable-mbstring --enable-soap --enable-xml --enable-zip --enable-bcmath
make ZEND_EXTRA_LIBS='-liconv' && make install

#��װsqlite
#http://www.sqlite.org/download.html
tar zxvf sqlite-autoconf-3081002.tar.gz  && cd   sqlite-autoconf-3081002
./configure --prefix=/usr/local/sqlite
make && make install

#cyrus-sasl
#ע���ɵ�cyrus-sasl
mv /usr/lib64/sasl2/ /usr/lib64/sasl2.OFF
tar zxvf cyrus-sasl-2.1.26.tar.gz && cd cyrus-sasl-2.1.26
./configure --disable-sample --disable-saslauthd --disable-pwcheck --disable-krb4 --disable-gssapi --disable-anon --enable-plain --enable-login --enable-cram --enable-digest --with-saslauthd=/var/run/saslauthd
make && make install
ln -s /usr/local/lib/sasl2/ /usr/lib64/sasl2
echo "/usr/local/lib/sasl2/lib" >> /etc/ld.so.conf
ldconfig

#��װsubversion
tar  jxvf subversion-1.8.13.tar.bz2 && cd  subversion-1.8.13
./configure --prefix=/usr/local/subversion --with-apxs=/usr/local/apache2/bin/apxs --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util/ --with-sqlite=/usr/local/sqlite/ --with-sasl=/usr/lib64/sasl2
make && make install
#�ڰ�װĿ¼������svn-toolsĿ¼�������һЩ��չ���ߣ�����svnauthz-validate
make install-tools

#########svnserve --version################
##Cyrus SASL authentication is available.##
###########################################

# $PATH
cat >> ~/.bashrc << EOF
APACHE_HOME=/Data/app/apache-2.4.12
SUBVERSION_HOME=/Data/app/subversion
PATH=$PATH:${APACHE_HOME}/bin:${SUBVERSION_HOME}/bin
export APACHE_HOME SUBVERSIOIN_HOME PATH
EOF

#Ϊapache���ģ��
cd $prefix
cp   libexec/mod_authz_svn.so  /usr/local/apache2/modules/
cp   libexec/mod_dav_svn.so  /usr/local/apache2/modules/

#��httpd.conf��ӣ�
LoadModule dav_module modules/mod_dav.so
LoadModule dav_svn_module modules/mod_dav_svn.so
LoadModule authz_svn_module modules/mod_authz_svn.so

#ȥ��Include /etc/httpd/extra/httpd-vhosts.conf��ǰע��ʹ֮��Ч

#��httpd-vhosts.conf�������������
<VirtualHost *:80>
    ServerName svn.happigo.com
    <Location /svn>                         #�����/svnҪ������AliasĿ¼����
        DAV svn
        SVNParentPath /data/svn      #svn�汾���Ŀ¼,��Ŀ¼���ж���汾��ʹ��SVNParentPath,�����汾���ʹ��SVNPath
        AuthType Basic
        AuthName "Subversion repository"    #��֤ҳ����ʾ��Ϣ
        AuthUserFile /data/svn/passwd          #�û�������
        Require valid-user                              # ֻ����ͨ����֤���û�����
        AuthzSVNAccessFile /data/svn/authz  #�汾��Ȩ�޿���
    </Location>
</VirtualHost>
# ����passwd��authz�ļ�

# ������֤�ļ�

# �û��������ļ���
htpasswd -c  /data/svn/passwd  user1  #�״�����û���������û�ʹ��-m��������

# �汾��Ȩ����֤�ļ�

vi  /data/svn/authz  #����svn�汾���µ�authz�ļ���ʽ�༭Ȩ�޼���

#  �����汾��

svnadmin  create /data/svn/test1

# ����
http://svn.xx.com/svn/test1


# ����apache  https

# ������Ҫ��װ��openssl,�ϱߵĲ������Ѿ���װ��

# apacheҪ����sslģ����߰�װapache��ʱ���Ѿ�ʹ��enable-ssl��̬������ssl

#httpd.conf��ȥ�������е�ע�ͣ�ʹ֮��Ч
LoadModule ssl_module modules/mod_ssl.so
LoadModule socache_shmcb_module modules/mod_socache_shmcb.so
Include /etc/httpd/extra/httpd-ssl.conf

#�༭httpd-ssl.conf�ļ�

<VirtualHost _default_:443>
ServerName svn.xx.com:443
<Location /svn>
        DAV svn
        SVNParentPath /data/svn
        AuthType Basic
        AuthName "Subversion repository"
        AuthUserFile /data/svn/passwd
        Require valid-user
        AuthzSVNAccessFile /data/svn/authz
</Location>
SSLEngine on
SSLCertificateFile "/etc/httpd/server.crt"     
SSLCertificateKeyFile "/etc/httpd/server.key"
</VirtualHost >

# ����ssl֤��
openssl genrsa  -des3 -out  server.key 1024 #des3 ��˽Կ������룬������ȫ��

openssl req -new   -key server.key  -out server.csr # ��˽Կƥ��Ĺ�Կ�����ӽ�����ù�Կ������ͻ���

openssl req -x509 -days 365 -signkey server.key -in server.csr  -out  server.crt #����Կǩ��������֤��

cp server.key server.key.with_pass

openssl rsa -in server.key.with_pass -out server.key # ����һ���������˽Կ��ר�Ÿ�apache��nginxʹ�õģ���Ϊ���������Ҫʹ��˽Կ�Կͻ���ʹ�õĹ�Կ������֤��ƥ���������

#�����ɵ������ļ��ŵ�/et/httpdĿ¼�£�/etc/httpdĿ¼����һ��httpd-ssl.conf��ָ���ģ�

# ����apache����

#����

https://svn.xx.com/svn/test1

#ע��������ģʽ�£�svn���񲢲�������ͨ��http��https������svn������svn�ύ���ݵ�ʱ��Ҫ��֤��������apache���û���svn�汾��Ŀ¼�ж�дȨ�ޣ���Ȼ��������db/txn-current-lock': Permission denied�� �Ĵ���

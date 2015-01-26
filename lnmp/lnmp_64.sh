#!/bin/bash
##lnmp_64.sh
# install nginx+php-fpm+mysql on centos X86_64
# you can custom sourcedir and app_dir,upload tarball to the $sourcedir ,then run this script
# php mysql will be installed to $app_dir
# modified by shidg    20150126

source_dir="/usr/local/src/lnmp/"
[ "$PWD" != "${source_dir}" ] && cd ${source_dir}

app_dir="/Data/app"

function ERRTRAP{
    echo "[LINE:$1] Error: exited with status $?"
    kill $!
    exit 1
}

function dots{
    while true;do
        for cha in '-' '\\' '|' '/'
        do
            echo -ne "executing...$cha\r"
            sleep 1
        done
    done
}

function success{
    echo
    echo "Successful!"
    kill $!
}

##########################
stty -echo

exec 6>&1
exec 7>&2
exec 1>/dev/null
exec 2>&1
#exec 1>&6 6>&-
#exec 2>&7 7>&-

trap 'ERRTRAP $LINENO' ERR

echo "install dependent libraries"
dots &
yum -y install gcc gcc-c++ libtool ncurses ncurses-devel openssl openssl-devel libxml2 libxml2-devel bison libXpm libXpm-devel fontconfig-devel libtiff libtiff-devel curl curl-devel readline readline-devel bzip2 bzip2-devel  sqlite sqlite-devel zlib zlib-devel

exec 1>&6
success
#ncurses  openssl bison Ϊ����mysql5����
#libXpm libXpm-devel fontconfig-devel libtiff libtiff-devel Ϊ��װgd��������

echo "install libiconv..."
dots &
exec 1>/dev/null
tar zxvf libiconv-1.14.tar.gz && cd libiconv-1.14 && ./configure --prefix=/usr && make && make install

exec 1>&6
success

## for CentOS 7 ##
#tar zxvf libiconv-1.14.tar.gz && cd libiconv-1.14 && ./configure --prefix=/usr
#(cd /Data/software/lnmp/libiconv-1.14;make)
#sed  -i -e '/_GL_WARN_ON_USE (gets/a\#endif' -e '/_GL_WARN_ON_USE (gets/i\#if defined(__GLIBC__) && !defined(__UCLIBC__) && !__GLIBC_PREREQ(2, 16)' srclib/stdio.h
#make && make install

cd ..
echo "install libxslt..."
dots &
exec 1>/dev/null
tar zxvf libxslt-1.1.28.tar.gz && cd libxslt-1.1.28

#�����/bin/rm: cannot remove `libtoolT��: No such file or directory ��
sed -i '/$RM "$cfgfile"/ s/^/#/' configure

./configure --prefix=/usr && make && make install
echo 'OK,libxslt-1.1.28 has  been successfully installed!'

exec 1>&6
success

cd ..
echo "install libmcrypt"
dots &
exec 1>/dev/null
tar zxvf libmcrypt-2.5.8.tar.gz && cd libmcrypt-2.5.8 && ./configure --prefix=/usr && make && make install

cd libltdl && ./configure --prefix=/usr/ --enable-ltdl-install && make && make install

exec 1>&6
success

cd ../../
echo "install mhash"
dots &
exec 1>/dev/null
tar jxvf mhash-0.9.9.9.tar.bz2 && cd mhash-0.9.9.9 && ./configure && make && make install
exec 1>&6
success

echo "/usr/local/lib" >> /etc/ld.so.conf
ldconfig

cd ..
echo "install mcrypt"
dots &
exec 1>/dev/null
tar zxvf mcrypt-2.6.8.tar.gz && cd mcrypt-2.6.8  && ./configure && make && make install
exec 1>&6
success

cd ..
echo "install libevent..."
dots &
exec 1>/dev/null
tar zxvf libevent-2.0.21-stable.tar.gz && cd libevent-2.0.21-stable && ./configure --prefix=/usr && make && make install
exec 1>&6
success

cd ..
echo "install libpng..."
dots &
exec 1>/dev/null
tar zxvf libpng-1.6.8.tar.gz && cd libpng-1.6.8 && ./configure --prefix=/usr && make && make install
#ln -s /usr/lib/libpng15.so.15.12.0  /usr/lib64/libpng15.so.15
exec 1>&6
success

cd ..
echo "install jpeg"
dots &
exec 1>/dev/null
tar zxvf jpegsrc.v9a.tar.gz && cd jpeg-9a && ./configure --prefix=/usr/local/jpeg --enable-shared --enable-static && make && make install
exec 1>&6
success

cd ..
echo "install freetype"
dots &
exec 1>/dev/null
tar zxvf freetype-2.5.3.tar.gz && cd freetype-2.5.3 && ./configure --prefix=/usr/local/freetype && make && make install
exec 1>&6
success

cd ..
echo "install gd2"
dots &
exec 1>/dev/null
tar jxvf libgd-2.1.0.bz2 && cd gd/2.1.0 && ./configure --prefix=/usr/local/gd --with-zlib --with-png=/usr --with-jpeg=/usr/local/jpeg --with-freetype=/usr/local/freetype --with-tiff=/usr/ && make && make install
exec 1>&6
success

cd ../../
echo "install cmake"
dots &
exec 1>/dev/null
tar zxvf cmake-3.1.0.tar.gz && cd cmake-3.1.0 && ./configure --prefix=/usr && make && make install
exec 1>&6
success

cd ..
echo "install mysql"
dots &
exec 1>/dev/null
#yum -y install ncurses ncurses-devel openssl openssl-devel
yum install bison
tar zxvf mysql-5.6.15.tar.gz && cd mysql-5.6.15 && cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql/ -DMYSQL_DATADIR=/data/mysql/data -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DENABLED_LOCAL_INFILE=1 -DMYSQL_TCP_PORT=3306 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DWITH_PARTITION_STORAGE_ENGINE=1 -DMYSQL_UNIX_ADDR=/tmp/mysql.sock -DWITH_DEBUG=0  -DWITH_SSL=yes -DSYSCONFDIR=/data/mysql -DMYSQL_TCP_PORT=3306 && make && make install
#-DWITH_MEMORY_STORAGE_ENGINE=1  -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1֧�ֵ��������ݿ����棬������Ҫ����
useradd -s /sbin/nologin www
useradd -s /sbin/nologin mysql
mkdir -p /data/mysql/{data,binlog,relaylog}
chown -R mysql:mysql /data/mysql
touch /data/mysql/my.cnf
echo -ne "[client]\ndefault-character-set=utf8\nport = 3306\nsocket = /tmp/mysql.sock\n[mysqld]\ncharacter-set-server = utf8\ncollation-server = utf8_general_ci\n#replicate-ignore-db = mysql\n#replicate-ignore-db = test\n#replicate-ignore-db = information_schema\nuser = mysql\nport = 3306\nsocket  = /tmp/mysql.sock\nbasedir = /usr/local/mysql\ndatadir = /data/mysql/data\nexplicit_defaults_for_timestamp=true\nlog-error = /data/mysql/mysql_error.log\npid-file = /data/mysql/mysql.pid\nopen_files_limit    = 10240\nback_log = 600\nmax_connections = 5000\nmax_connect_errors = 6000\nexternal-locking = FALSE\nmax_allowed_packet = 32M\nsort_buffer_size = 1M\njoin_buffer_size = 1M\nthread_cache_size = 300\nthread_concurrency = 8\nquery_cache_size = 512M\nquery_cache_limit = 2M\nquery_cache_min_res_unit = 2k\ndefault-storage-engine = MyISAM\nthread_stack = 192K\ntransaction_isolation = READ-COMMITTED\ntmp_table_size = 246M\nmax_heap_table_size = 246M\nlong_query_time = 3\nlog-slave-updates\nlog-bin = /data/mysql/binlog/binlog\nbinlog_cache_size = 4M\nbinlog_format = MIXED\nmax_binlog_cache_size = 8M\nmax_binlog_size = 1G\nexpire-logs-days = 30\nrelay-log-index = /data/mysql/relaylog/relaylog\nrelay-log-info-file = /data/mysql/relaylog/relaylog\nrelay-log = /data/mysql/relaylog/relaylog\nexpire_logs_days = 30\nkey_buffer_size = 256M\nread_buffer_size = 1M\nread_rnd_buffer_size = 16M\nbulk_insert_buffer_size = 64M\nmyisam_sort_buffer_size = 128M\nmyisam_max_sort_file_size = 10G\nmyisam_repair_threads = 1\n;myisam_recover\n\ninteractive_timeout = 120\nwait_timeout = 120\n\nskip-name-resolve\nslave-skip-errors = 1032,1062,126,1114,1146,1048,1396\n\nserver-id = 1\n\n;innodb_additional_mem_pool_size = 16M\n;innodb_buffer_pool_size = 512M\n;innodb_data_file_path = ibdata1:256M:autoextend\n;innodb_file_io_threads = 4\n;innodb_thread_concurrency = 8\n;innodb_flush_log_at_trx_commit = 2\n;innodb_log_buffer_size = 16M\n;innodb_log_file_size = 128M\n;innodb_log_files_in_group = 3\n;innodb_max_dirty_pages_pct = 90\n;innodb_lock_wait_timeout = 120\n;innodb_file_per_table = 0\n\nslow_query_log\nslow_query_log_file = /data/mysql/slow.log\nlong_query_time = 1\nlog-queries-not-using-indexes\n\n[mysqldump]\nquick\nmax_allowed_packet = 32M\n" >> /data/mysql/my.cnf
ln -s /data/mysql/my.cnf /etc/my.cnf
cp /usr/local/mysql/bin/mysql* /usr/bin/ && cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld && chmod +x /etc/init.d/mysqld
chkconfig --level 3 mysqld on

#������mysql������¼
if [ -f /root/.mysql_history ];then
rm -f /root/.mysql_history && ln -s /dev/null /root/.mysql_history
fi
exec 1>&6
success

#PHP-5.3.16
cd ..
echo "install php"
dots &
exec 1>/dev/null
tar zxvf php-5.5.8.tar.gz && cd php-5.5.8 && ./configure --prefix=/usr/local/php5.5.8  --with-config-file-path=/usr/local/php5.5.8/etc --with-libxml-dir --with-iconv-dir --with-png-dir --with-jpeg-dir=/usr/local/jpeg --with-zlib --with-gd=/usr/local/gd --with-freetype-dir=/usr/local/freetype --with-mcrypt=/usr --with-mhash --enable-gd-native-ttf  --with-curl --with-bz2 --enable-mysqlnd --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-openssl-dir --without-pear --enable-fpm --enable-mbstring --enable-soap --enable-xml --enable-pdo --enable-ftp  --enable-zip --enable-bcmath --enable-sockets --enable-opcache && make && make install
cp ../{php.ini,php-fpm.conf} /usr/local/php-5.5.8/etc/ && mkdir /usr/local/php-5.5.8/ext
ln -s /usr/local/php-5.5.8  /usr/local/php
if [ ! -d /data/logs/php ];then
mkdir -p /data/logs/php #��־���Ŀ¼
fi

exec 1>&6
success

#openssl
#cd ext/openssl
#mv mv config0.m4 config.m4
#/usr/local/php/bin/phpize
#./configure --with-openssl --with-php-config=/usr/local/php/bin/php-config && make && make install
#cp /usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/openssl.so /usr/local/php/ext
#cd ..
#PHP-5.2.17
#cd ..
#tar zxvf php-5.2.17.tar.gz && cd php-5.2.17
#patch -p1 < ../php-5.2.17-fpm-0.5.14.diff && ./buildconf --force
#rm -f /usr/lib/libxml2.so.2.6.26 && cp /usr/lib/libxml2.so.2.7.4 /usr/lib64 && rm -f /usr/lib64/{libxml2.so,libxml2.so.2} && ln -s /usr/lib64/libxml2.so.2.7.4 /usr/lib64/libxml2.so && ln -s /usr/lib64/libxml2.so.2.7.4 /usr/lib64/libxml2.so.2 && ln -s /usr/lib/libpng14.so.14.4.0 /usr/lib64/libpng14.so.14
#./configure --prefix=/usr/local/php-5.2.17 --with-config-file-path=/usr/local/php/etc --with-libxml-dir  --with-iconv-dir --with-png-dir --with-jpeg-dir=/usr/local/jpeg --with-zlib --with-gd=/usr/local/gd --with-freetype-dir=/usr/local/freetype --with-mcrypt --with-mhash --enable-gd-native-ttf --with-readline --with-curl --with-bz2 --with-mysql=/usr/local/mysql --with-mysqli=/usr/local/mysql/bin/mysql_config --with-openssl-dir --enable-fpm --enable-fastcgi --enable-mbstring --enable-soap --enable-xml --enable-pdo --enable-ftp --without-safe-mode --enable-zip  --enable-bcmath  --enable-sockets && make && make install
#cp php.ini-dist /usr/local/php/etc && cp /usr/local/php/sbin/php-fpm /etc/init.d/ && chmod +x /etc/init.d/php-fpm && mkdir /usr/local/php/ext
#echo  'OK,PHP-5.2.17 has  been successfully installed!'
#sleep 2

cd ..
echo "install nginx"
dots &
exec 1>/dev/null
#����ngx_cache_purgeģ��
#wget http://labs.frickle.com/files/ngx_cache_purge-1.5.tar.gz && tar zxvf ngx_cache_purge-1.5.tar.gz
#tar zxvf pcre-8.30.tar.gz && mv pcre-8.30  /usr/local/ && tar zxvf openssl-1.0.1c.tar.gz && mv openssl-1.0.1c /usr/local/ && tar zxvf nginx-1.2.3.tar.gz && cd nginx-1.2.3 && ./configure --prefix=/usr/local/nginx --add-module=../ngx_cache_purge-1.5 --with-pcre=/usr/local/pcre-8.30 --with-openssl=/usr/local/openssl-1.0.1c --with-http_sub_module --with-http_ssl_module --with-http_stub_status_module && make && make install 

tar jxvf pcre-8.36.tar.bz2 && mv pcre-8.36  /usr/local/ && tar zxvf openssl-1.0.1j.tar.gz && mv openssl-1.0.1j/usr/local/ && tar zxvf nginx-1.6.2.tar.gz && cd nginx-1.6.2 && ./configure --prefix=/usr/local/nginx  --with-pcre=/usr/local/pcre-8.36 --with-openssl=/usr/local/openssl-1.0.1j --with-http_sub_module --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module && make && make install
cat ../nginx.conf > /usr/local/nginx/conf/nginx.conf

exec 1>&6
success

cd ..
echo "install re2c"
dots &
exec 1>/dev/null
tar zxvf re2c-0.13.7.5.tar.gz && cd re2c-0.13.7.5 && ./configure && make && make install
exec 1>&6
success

#cd ..
#echo "Start the installation of memcached..."
#sleep 3
#tar zxvf memcached-1.4.17.tar.gz && cd memcached-1.4.17 && ./configure --prefix=/usr/local/memcached --with-libevent && make && make install
#echo "OK,memcached-1.4.17 has  been successfully installed!"
#sleep 2

#echo "Starting memcached,please wait...."
#sleep 2
#/usr/local/memcached/bin/memcached -d -m 256 -u root -P /tmp/memcached.pid && echo "OK,memcached is runing now" 
#echo "/usr/local/memcached/bin/memcached -d -m 256 -u root -P /tmp/memcached.pid" >> /etc/rc.d/rc.local
#sleep 2

#cd .. 
#echo "Start install memcache extension..."
#���php�汾Ϊ5.2����memcacheʹ��2.2.6�汾���������汾���⵼��php�޷�����memcachģ�顣
#sleep 2
#tar zxvf memcache-3.0.8.tgz && cd memcache-3.0.8 && /usr/local/php/bin/phpize && ./configure --enable-memcache --with-php-config=/usr/local/php/bin/php-config && make && make install 
#cp /usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/memcache.so /usr/local/php/ext/
#echo  "OK,Memcache-3.0.6 installed successfully!"

#cd ..
#echo "Start install pdf extension..."
#tar zxvf PDFlib-Lite-7.0.5p3.tar.gz && cd PDFlib-Lite-7.0.5p3.tar.gz
#./configure --prefix=/Data/app/pdflib && make && make install
#cd ..
#tar zxvf pdflib-3.0.4.tgz && cd pdflib-3.0.4.tgz
#${php_prefix}/bin/phpize
#./configure --with-php-config=/Data/app/php/bin/php-config --with-pdflib=/Data/app/pdflib/
#make && make install

#cd ..
#echo "Start install ImageMagick..."
#sleep 2
#tar zxvf ImageMagick-6.8.8-2.tar.gz && cd ImageMagick-6.8.8-2&& ./configure --prefix=/usr/local/imagemagick && make && make install
#echo "/usr/local/imagemagick/lib" >> /etc/ld.so.conf && ldconfig
#echo "OK,ImageMagick-6.8.8-2 has been installed successfully!"
#sleep 2

#cd ..
#echo "Start install imagick for php ..."
#tar zxvf imagick-3.1.2.tgz && cd imagick-3.1.2 && /usr/local/php/bin/phpize && ./configure --with-imagick=/usr/local/imagemagick --with-php-config=/usr/local/php/bin/php-config && make && make install
#cp /usr/local/php/lib/php/extensions/no-debug-non-zts-20060613/imagick.so  /usr/local/php/ext/
#echo "OK,imagick-3.1.2 for php has been installed successfully!"
#sleep 2

#php5.3֮����Ҫ�ٵ�����װPDO_MYSQL
#cd ..
#echo "Start install PDO_MYSQL ..."
#tar zxvf PDO_MYSQL-1.0.2.tgz && cd PDO_MYSQL-1.0.2 && /usr/local/php/bin/phpize && ./configure --with-php-config=/usr/local/php/bin/php-config --with-pdo-mysql=/usr/local/mysql && make && make install
#cp modules/pdo_mysql.so /usr/local/php/ext/
#echo "OK,PDO_MYSQL-1.0.2 has been installed successfully!"

#cd ..
#echo "Start install APC ..."
#tar zxvf APC-3.1.9.tgz && cd APC-3.1.9 
#/usr/local/php/bin/phpize
#./configure --enable-apc --with-apc-mmap --with-php-config=/usr/local/php/bin/php-config && make && make install
#cp /usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/apc.so /usr/local/php/ext/
#echo -ne "[APC]\nextension = \"apc.so\"\napc.enabled = 1\napc.cache_by_default = on\napc.shm_size = 32M\napc.ttl = 600\napc.user_ttl = 600\napc.write_lock = on" >> /usr/local/php/etc/php.ini
#echo -ne "APC-3.1.9 has been installed successfully!"
#cd ..

#yaf.so
#tar zxvf yaf-2.3.3.tgz && cd yaf-2.3.3 
#/usr/local/php/bin/phpize && ./configure --with-php-config=/usr/local/php/bin/php-config && make && make install
#cp /usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/yaf.so /usr/local/php/ext/

echo "others"
dots &
exec 1>/dev/null

#nginx/mysql/php auto running
echo "/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf" >> /etc/rc.d/rc.local
echo "/usr/local/php/sbin/php-fpm" >> /etc/rc.d/rc.local

#ulimit
sed -i '$i *                -       nofile          65535\
*                soft    core            0\
*                hard    core            0' /etc/security/limits.conf

#sysctl.conf
cat sysctl.conf >> /etc/sysctl.conf && chown root:root /etc/sysctl.conf && chmod 0600 /etc/sysctl.conf

#history��������ʱ��
sed -i '/HISTSIZE/a HISTTIMEFORMAT="`who am i`:%Y%m%d-%H%M%S:"'  /etc/profile
sed -i '/export/ s/$/ HISTTIMEFORMAT/' /etc/profile

#su/sudo
#��wheel���Ա����ʹ��su
sed -i '/required/ s/^#//' /etc/pam.d/su
echo "SU_WHEEL_ONLY  yes" >> /etc/login.defs

#sudo
#Cmnd_Alias MANAGER = /sbin/route, /sbin/ifconfig, /bin/ping, /sbin/iptables, /sbin/service, /sbin/chkconfig, /bin/chmod, /bin/chown, /bin/chgrp
#User_Alias ADMINS = 

#root    ALL=(ALL)     ALL
#ADMINS  ALL=(ALL)     MANAGER

#vim_editor
exec 1&6
success
echo -ne "OK,That is all!\nThanks \n"

#10���Ӻ�����
echo -n "reboot system right now?[Y/n]"
read -n 1 answer
case $answer in
Y|y) echo 
for i in $(seq -w 10| tac)
do
        echo -ne "\aThe system will reboot after $i seconds...\r"
        sleep 1
done
echo
shutdown -r now  
;;
N|n)
echo
;;
esac
exit 0

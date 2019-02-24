FROM centos:7
MAINTAINER "Tom" <tom_hejiaxi@163.com>

ENV PHP_VERSION 7.2.10
ENV TMP_PATH /tmp/uve_core_install

#install php src
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
    rm -f /lib/systemd/system/multi-user.target.wants/*;\
    rm -f /etc/systemd/system/*.wants/*;\
    rm -f /lib/systemd/system/local-fs.target.wants/*; \
    rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
    rm -f /lib/systemd/system/basic.target.wants/*;\
    rm -f /lib/systemd/system/anaconda.target.wants/*;\
    readonly NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1); \
    echo "NPROC=$NPROC"; \
    echo "Installing packages..."; \
    yum install -y gcc gcc-c++ automake autoconf wget git bzip2 bzip2-devel libjpeg-devel libvpx-devel freetype-devel libpng-devel libmcrypt-devel libXpm-devel pcre pcre-devel openssl openssl-devel gd gd-devel libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel curl curl-devel libcurl libcurl-devel wget zlib zlib-devel; \
    echo "Install php..."; \
    wget http://cn2.php.net/get/php-${PHP_VERSION}.tar.bz2/from/this/mirror -O php-${PHP_VERSION}.tar.bz2; \
    tar xjf php-${PHP_VERSION}.tar.bz2; \
    cd php-${PHP_VERSION}; \
    echo "Configure PHP..."; \
    ./configure --prefix=/usr/local/php --enable-fpm --with-fpm-user=deployer --with-fpm-group=deployer --enable-opcache --enable-phpdbg --enable-phpdbg-webhelper --with-openssl  --with-zlib --enable-calendar --enable-bcmath --with-bz2 --with-curl --with-gd --with-jpeg-dir --with-png-dir --with-freetype-dir --with-gettext --enable-mbstring --disable-mbregex --with-mcrypt --with-mysqli --enable-pcntl --enable-shmop --enable-sockets --enable-sysvsem --enable-shmop --with-mhash --with-mysql-sock --enable-pdo --with-pdo-mysql; \
    echo "Compiling PHP..."; \
    make -j${NPROC}; \
    make install;

ENV PATH=$PATH:/usr/local/php/bin
#Add user
RUN set -x; \
    useradd -r -s /bin/bash -m -k no www; \
    useradd -r -s /bin/bash -m -k no deployer; \
    mkdir $TMP_PATH; \
    cd $TMP_PATH; \ 
    wget https://cmake.org/files/v3.11/cmake-3.11.4.tar.gz; \
    tar -zxvf cmake-3.11.4.tar.gz; \
    cd cmake-3.11.4; \
    ./configure; \
    make && make install; \
    cd $TMP_PATH; \ 
    echo "Install PHP igbinary extension..."; \
    git clone https://github.com/igbinary/igbinary;\
    cd igbinary;\
    /usr/local/php/bin/phpize;\
    ./configure CFLAGS="-O2 -g" --enable-igbinary --with-php-config=/usr/local/php/bin/php-config;\
    make && make install ; \
    cd $TMP_PATH; \
    echo "Install PHP zip extension..."; \
    wget https://libzip.org/download/libzip-1.5.1.tar.gz; \
    tar -zxvf libzip-1.5.1.tar.gz; \
    cd libzip-1.5.1; \
    mkdir build && cd build && cmake .. && make && make install; \
    cp lib/libzip.so* /lib64/; \
    /usr/local/php/bin/pecl install zip;

#install composer
RUN echo "Install composer..."; \
    curl -sS https://getcomposer.org/installer | /usr/local/php/bin/php;mv composer.phar /usr/local/bin/composer

COPY start.sh /start.sh
RUN echo "Clean ..."; \
    rm -rf /usr/local/php/etc; \
    echo "Done"; \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime; \
    mkdir -p /data1/log/php/; \
    chmod +x /start.sh;
COPY etc/php-fpm.conf /usr/local/php/etc/php-fpm.conf
COPY etc/php.ini /usr/local/php/lib/php.ini

CMD ["/start.sh"]

FROM tomhjx/fpm:7.2.10-centos7
RUN /usr/local/php/bin/pecl install redis;
RUN /usr/local/php/bin/pecl install mongodb;

COPY etc/php-fpm.conf /usr/local/php/etc/php-fpm.conf
COPY etc/php.ini /usr/local/php/lib/php.ini
COPY start.sh /start.sh
RUN  chmod +x /start.sh;

CMD ["/start.sh"]

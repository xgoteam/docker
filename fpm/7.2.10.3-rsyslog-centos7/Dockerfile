FROM xgoteam/fpm:7.2.10.3-centos7

RUN yum install -y rsyslog

COPY etc/php-fpm.conf /usr/local/php/etc/php-fpm.conf
COPY etc/php.ini /usr/local/php/lib/php.ini
COPY etc/rsyslog.conf /etc/rsyslog.conf
COPY etc/rsyslog.d /etc/rsyslog.d
COPY start.sh /start.sh
RUN  chmod +x /start.sh;

CMD ["/start.sh"]

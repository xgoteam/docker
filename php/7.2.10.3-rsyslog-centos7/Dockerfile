FROM xgoteam/php:7.2.10.3-centos7
RUN yum install -y rsyslog
COPY etc/rsyslog.conf /etc/rsyslog.conf
COPY etc/rsyslog.d /etc/rsyslog.d
COPY etc/php.ini /usr/local/php/lib/php.ini
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php", "-v"]

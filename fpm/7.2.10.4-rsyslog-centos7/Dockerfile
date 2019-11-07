FROM xgoteam/fpm:7.2.10.3-rsyslog-centos7

COPY etc/php-fpm.conf /usr/local/php/etc/php-fpm.conf
COPY etc/php.ini /usr/local/php/lib/php.ini
COPY start.sh /start.sh
COPY entrypoint.sh /entrypoint.sh
RUN  chmod +x /start.sh; \
     chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/start.sh"]

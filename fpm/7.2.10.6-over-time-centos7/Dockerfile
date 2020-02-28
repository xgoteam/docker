FROM xgoteam/fpm:7.2.10.4-rsyslog-centos7
#复制fxhook扩展
COPY ext/fxhook.so /usr/local/php/lib/php/extensions/no-debug-non-zts-20170718/fxhook.so

COPY etc/php-fpm.conf /usr/local/php/etc/php-fpm.conf
COPY etc/php.ini /usr/local/php/lib/php.ini
COPY start.sh /start.sh
RUN  chmod +x /start.sh; \
     chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/start.sh"]

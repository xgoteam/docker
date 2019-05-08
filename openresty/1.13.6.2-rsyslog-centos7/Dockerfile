FROM xgoteam/openresty:1.13.6.2-centos7

RUN yum install -y rsyslog

COPY etc/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY etc/conf.d /etc/nginx/conf.d
COPY etc/rsyslog.conf /etc/rsyslog.conf
COPY start.sh /start.sh
COPY entrypoint.sh /entrypoint.sh
RUN  chmod +x /start.sh; \
     chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/start.sh"]

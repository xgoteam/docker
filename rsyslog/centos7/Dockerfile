FROM centos:7
MAINTAINER "Tom" <tom_hejiaxi@163.com>
RUN yum install -y rsyslog
COPY etc/rsyslog.conf /etc/rsyslog.conf
COPY etc/rsyslog.d /etc/rsyslog.d
COPY start.sh /start.sh
RUN  chmod +x /start.sh; \
     cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime;

CMD ["/start.sh"]

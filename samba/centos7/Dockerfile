# Dockerfile - CentOS 7
# https://github.com/openresty/docker-openresty
FROM centos:7
LABEL maintainer="Tom <tom_hejiaxi@163.com>"
RUN yum install -y samba
COPY start.sh /start.sh
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && chmod +x /start.sh

CMD ["/start.sh"]

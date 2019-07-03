FROM xgoteam/python36:latest

RUN yum install -y mysql-devel gcc libXext libSM libXrender
RUN yum groupinstall -y "Development tools"

# supervisor installation
RUN pip3.6 install supervisor

RUN mkdir -p /etc/supervisord.d/
ADD etc/supervisord.conf /etc/supervisord.conf
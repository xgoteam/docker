FROM centos:7

RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    PIPENV_VENV_IN_PROJECT=1

RUN rpm --import /etc/pki/rpm-gpg/RPM* 


RUN yum update -y
RUN yum install -y epel-release \
    && yum install -y https://centos7.iuscommunity.org/ius-release.rpm \
    && yum install -y python36u python36u-libs python36u-devel python36u-pip \
    && yum install -y rsyslog \
    && yum install -y git

RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# pipenv installation
RUN pip3.6 install pipenv

# pip upgrade
RUN pip3.6 install --upgrade pip

ADD etc/rsyslog.conf /etc/rsyslog.conf

RUN python3.6 --version
RUN pipenv --version
RUN pip3.6 --version

RUN mkdir /work
COPY start.sh /work/start.sh
CMD /work/start.sh
# Use an official centos7 image
FROM cielpy/centos7-python36-supervisor:latest

RUN yum install -y git
WORKDIR /work

COPY Pipfile /work
COPY Pipfile.lock /work

RUN pipenv --python 3.6
RUN pipenv install --deploy

RUN mkdir -p /work/log

COPY email_notification.py /work


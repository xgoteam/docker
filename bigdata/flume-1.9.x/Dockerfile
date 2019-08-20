FROM alpine

RUN apk update \
        && apk upgrade \
        && apk add --no-cache bash \
        bash-doc \
        bash-completion \
        && rm -rf /var/cache/apk/* \
        && /bin/bash

WORKDIR /opt/tools/
COPY src/apache-flume-1.9.0-bin /opt/tools/apache-flume-1.9.0-bin

ENV FLUME_HOME=/opt/tools/apache-flume-1.9.0-bin
ENV PATH=$PATH:$FLUME_HOME/bin

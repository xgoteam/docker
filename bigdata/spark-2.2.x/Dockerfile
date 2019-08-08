FROM maven:3.6.1-jdk-8-alpine

COPY src /opt/src

RUN cd /opt/src; \
    mvn package -Pdev,shade

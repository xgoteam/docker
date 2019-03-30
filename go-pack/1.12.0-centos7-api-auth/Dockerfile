FROM xgoteam/go:1.12.0-centos7
COPY src /app/src
ENV GO111MODULE on
RUN cd /app/src; \
    go mod tidy
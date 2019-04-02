FROM xgoteam/go:1.12.0-centos7
COPY src /pack/src
ENV GO111MODULE on
RUN cd /pack/src; \
    go mod tidy
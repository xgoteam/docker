# 临时基础镜像
FROM node:12.13.0-slim
COPY app /app

RUN mkdir -p /var/log/app; \
    chmod 777 -R /var/log/app; \
    mkdir -p /root/.npm/_logs; \
    chmod 777 -R /root/.npm/_logs; \
    cd /app; \
    npm install; \
    npm audit fix

VOLUME ["/src", "/app/dist"]

WORKDIR /app
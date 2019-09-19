FROM node:8
LABEL maintainer="junming.zeng@xgo.one"

# Create app directory
WORKDIR /app
COPY etc /app
# 阿里云oss上传工具
RUN wget http://gosspublic.alicdn.com/ossutil/1.6.0/ossutil64 \
 && chmod 755 ossutil64
# 下载项目基础依赖
RUN npm install
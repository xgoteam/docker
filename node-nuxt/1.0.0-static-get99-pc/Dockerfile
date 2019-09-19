# 构建命令例子（正式环境） - docker build --no-cache --build-arg BUILD_ENV=city .
FROM xgoteam/node-nuxt:1.0.0-nuxt-oss-node8
LABEL maintainer="junming.zeng@xgo.one"

# 定义构建环境
ARG BUILD_ENV=prod

# Create app directory
WORKDIR /app

#拷贝整个源码到工作目录
COPY src /app

# 更新项目基础依赖
RUN npm install

# 构建项目基础依赖
RUN npm run build:${BUILD_ENV}
RUN chmod +x deploy.sh

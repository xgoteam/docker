# docker
docker

https://cloud.docker.com/u/xgoteam/repository/list


# 目录结构

```
./
├── README.md
├── build.sh                    (构建镜像脚本)
├── push.sh                     (推送镜像脚本)
└── fpm                         (docker仓库名称)
    ├── 7.2.10-centos7         （tag名称）
    ├── 7.2.10.1-centos7
    └── 7.2.10.2-centos7


```

# 构建镜像

```bash

./build.sh fpm/7.2.10-centos7

```


# 构建并推送镜像

```bash

./push.sh fpm/7.2.10-centos7

```

推送后，可从docker hub拉取该镜像

```bash

docker pull xgoteam/fpm:7.2.10.2-centos7

```


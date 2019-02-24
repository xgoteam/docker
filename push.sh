#!/bin/bash

path=$1
img_full_name=${path////:}

./build.sh ${path}

docker push xgoteam/${img_full_name}
#!/bin/bash

path=$1
img_full_name=${path////:}

docker build ./${path} -t xgoteam/${img_full_name}
#!/bin/bash

path=$1
img_full_name=${path////:}

./build.sh ${path}

docker push hiiilife/${img_full_name}
#!/bin/bash

/usr/sbin/rsyslogd

mkdir -p /data1/log/php
/usr/local/php/sbin/php-fpm

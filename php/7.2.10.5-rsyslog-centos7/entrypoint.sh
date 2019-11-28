#!/bin/sh
/usr/sbin/rsyslogd
nohup /lua/kg_hook_reporter > /dev/null 2>&1 &
exec "$@"
#!/bin/bash
# Default IP address
TARGET_IP="172.16.100.145"

# If an argument is provided, use it as the target IP
if [ $# -ge 1 ]; then
    TARGET_IP="172.16.100.$1"
fi

rsync -av /home/$(whoami)/ptx/local_src/ipt4-web/wwwroot/dist/ root@${TARGET_IP}:/var/www/
#ssh root@ipt4-test1 '/etc/init.d/ipt4-daemon start'

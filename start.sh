#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) 
folder=$(echo $path | awk -F/ '{print $NF}')

docker stop popnode
docker rm popnode

docker run -d \
  --name popnode \
  -p 80:80 \
  -p 443:443 \
  -v /opt/popcache:/app \
  -w /app \
  -e POP_INVITE_CODE=9ecb5a723028d943 \
  --restart unless-stopped \
  popnode

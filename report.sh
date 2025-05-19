#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
json=/root/logs/report-$folder
source /root/.bash_profile
source $path/env

version=$(docker exec -it popnode ./pop --version | awk '{print $NF}' | sed 's/\r//g')
container=$(docker ps -a | grep "popnode" | awk '{print $NF}')
docker_status=$(docker inspect $container | jq -r .[].State.Status)
errors=$(journalctl -u $folder.service --since "1 hour ago" --no-hostname -o cat | grep -c -E "rror|ERR")

json1=$(curl -sk https://localhost/health)
mem_hits=$(echo $json1 | jq -r .memory_cache.hits)/$(echo $json1 | jq -r .memory_cache.misses)
disk_hits=$(echo $json1 | jq -r .disk_cache.hits)/$(echo $json1 | jq -r .disk_cache.misses)

status="ok" && message="hits $mem_hits $disk_hits"
[ $errors -gt 500 ] && status="warning" && message="hits $mem_hits $disk_hits errors=$errors"
[ "$docker_status" != "running" ] && status="error" && message="docker not running ($docker_status)"

cat >$json << EOF
{
  "updated":"$(date --utc +%FT%TZ)",
  "measurement":"report",
  "tags": {
       "id":"$folder-$ID",
       "machine":"$MACHINE",
       "grp":"node",
       "owner":"$OWNER"
  },
  "fields": {
        "chain":"testnet",
        "network":"testnet",
        "version":"$version",
        "status":"$status",
        "message":"$message",
        "docker_status":"$docker_status",
        "errors":$errors,
        "url":""
  }
}
EOF

cat $json | jq

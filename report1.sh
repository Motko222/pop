#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
folder=$(echo $path | awk -F/ '{print $NF}')
json=/root/logs/report-$folder
source /root/.bash_profile
source $path/env

version=$()
container=$(docker ps -a | grep "popnode" | awk '{print $NF}')
docker_status=$(docker inspect $container | jq -r .[].State.Status)
service=$(sudo systemctl status $folder --no-pager | grep "active (running)" | wc -l)
errors=$(journalctl -u $folder.service --since "1 hour ago" --no-hostname -o cat | grep -c -E "rror|ERR")

json1=$(curl -sk https://localhost/health)
mem_hits=$(echo $json1 | jq -r .memory_cache.hits)/$(echo $json1 | jq -r .memory_cache.misses)
disk_hits=$(echo $json1 | jq -r .disk_cache.hits)/$(echo $json1 | jq -r .disk_cache.misses)

status="ok" && message="hits $mem_hits $disk_hits"
[ $errors -gt 500 ] && status="warning" && message="hits $mem_hits $disk_hits errors=$errors";
[ "$docker_status" -ne "running" ] && status="error" && message="not running"

cat >$json << EOF
{
  "updated":"$(date --utc +%FT%TZ)",
  "measurement":"report",
  "tags": {
       "id":"folder-$ID",
       "machine":"$MACHINE",
       "grp":"node",
       "owner":"$OWNER"
  },
  "fields": {
        "chain":"?",
        "network":"?",
        "version":"$version",
        "status":"$status",
        "message":"$message",
        "service":$service,
        "errors":$errors,
        "url":"",
        "balance":"$balance"
  }
}
EOF

cat $json | jq

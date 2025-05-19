#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) 
folder=$(echo $path | awk -F/ '{print $NF}')

curl -sk https://localhost/health | jq
curl -sk https://localhost/state | jq
curl -sk https://localhost/metrics | jq

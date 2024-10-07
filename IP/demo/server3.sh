#!/bin/bash
echo " sysctl net.ipv4.conf.all.src_valid_mark=1"
sysctl net.ipv4.conf.all.src_valid_mark=1

docker compose -f compose-server3.yaml up  
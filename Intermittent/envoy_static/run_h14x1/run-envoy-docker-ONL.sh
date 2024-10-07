#!/bin/bash
ID=141
ADMINP=9${ID}
docker pull envoyproxy/envoy-dev:448cbd60ee4e1af1f869f9f519095680b233f1e2

STATSINK=0
if [ $# -gt 0 ]
then
	STATSINK=$1
fi

docker run --rm -p 0.0.0.0:18080:18080/tcp -p 0.0.0.0:9001:9001 -v "$PWD":/etc/envoy/ --name envoy -t envoyproxy/envoy-dev:448cbd60ee4e1af1f869f9f519095680b233f1e2 > dockerLog.txt 2>&1 &

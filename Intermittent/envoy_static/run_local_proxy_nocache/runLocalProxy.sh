#!/bin/sh

docker pull envoyproxy/envoy-dev:448cbd60ee4e1af1f869f9f519095680b233f1e2
nohup docker run --rm -p 0.0.0.0:12000:12000 -p 0.0.0.0:9001:9001 --network host -v "$PWD":/etc/envoy/ --name Local -t envoyproxy/envoy-dev:448cbd60ee4e1af1f869f9f519095680b233f1e2 > dockerLog.txt 2>&1 &


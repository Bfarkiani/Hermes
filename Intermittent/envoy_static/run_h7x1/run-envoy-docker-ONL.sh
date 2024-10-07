#!/bin/sh
docker pull envoyproxy/envoy-dev:448cbd60ee4e1af1f869f9f519095680b233f1e2
docker run --rm -p 0.0.0.0:18080:18080 -p 0.0.0.0:9001:9001 -v "$PWD":/etc/envoy/ --name envoyhttp -t envoyproxy/envoy-dev:448cbd60ee4e1af1f869f9f519095680b233f1e2  > dockerLog.txt 2>&1 &

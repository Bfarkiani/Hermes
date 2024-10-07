#!/bin/sh
docker pull envoyproxy/envoy-dev:448cbd60ee4e1af1f869f9f519095680b233f1e2
docker stop Local
nohup docker run --rm -p 0.0.0.0:10000:10000 -p 9001:9001 -p 7000:7000/tcp -p 7000:7000/udp --network host --cap-add=NET_ADMIN --cap-add=CAP_NET_ADMIN --cap-add=NET_BIND_SERVICE --cap-add=NET_RAW -v "$PWD":/etc/envoy/ --name Local -t envoyproxy/envoy-dev:448cbd60ee4e1af1f869f9f519095680b233f1e2 > dockerLog.txt 2>&1 &

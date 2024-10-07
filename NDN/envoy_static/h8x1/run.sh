#!/bin/sh

#envoy -c  envoy.yaml  --concurrency 1

docker pull envoyproxy/envoy-dev:448cbd60ee4e1af1f869f9f519095680b233f1e2
#docker run --rm --cap-add=NET_ADMIN --cap-add=CAP_NET_ADMIN --cap-add=NET_BIND_SERVICE --cap-add=NET_RAW -p 0.0.0.0:9001:9001 -p 0.0.0.0:6362:6362/udp -p 0.0.0.0:26363:26363/udp -v "$PWD":/etc/envoy --name Server1 -t envoyproxy/envoy-dev:448cbd60ee4e1af1f869f9f519095680b233f1e2
nohup docker run --rm -p 0.0.0.0:9001:9001 -p 0.0.0.0:7000:7000 -p 0.0.0.0:7000:7000/udp -p 0.0.0.0:12000:12000/udp -p 0.0.0.0:12000:12000/tcp -p 0.0.0.0:13000:13000/udp -p 0.0.0.0:13000:13000/tcp --network host -v "$PWD":/etc/envoy --name ndnEnvoyServer -t envoyproxy/envoy-dev:448cbd60ee4e1af1f869f9f519095680b233f1e2 > h8x1_Log.txt 2>&1 &

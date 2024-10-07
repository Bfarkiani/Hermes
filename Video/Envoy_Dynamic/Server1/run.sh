#!/bin/sh
docker pull envoyproxy/envoy-dev:448cbd60ee4e1af1f869f9f519095680b233f1e2
echo "Running Envoy"
docker stop Server1

docker rm Server1
nohup docker run --restart on-failure --cap-add=NET_ADMIN --cap-add=CAP_NET_ADMIN --cap-add=NET_BIND_SERVICE --cap-add=NET_RAW -p 0.0.0.0:10000:10000 -p 0.0.0.0:7000:7000/udp -v "$PWD":/etc/envoy --name Server1 -t envoyproxy/envoy-dev:448cbd60ee4e1af1f869f9f519095680b233f1e2 > dockerLog.txt 2>&1 &
echo "Running Video Server"
nohup python3 Server.py > serverLog.txt 2>&1 &
echo "Done"
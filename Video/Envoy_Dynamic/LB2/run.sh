#!/bin/sh
docker pull envoyproxy/envoy-dev:448cbd60ee4e1af1f869f9f519095680b233f1e2
docker stop LB2
nohup docker run --rm -p 0.0.0.0:9001:9001 -p 0.0.0.0:10000:10000 -p 0.0.0.0:8002:8002 -p 7000:7000/tcp -p 7000:7000/udp --cap-add=NET_ADMIN --cap-add=CAP_NET_ADMIN --cap-add=NET_BIND_SERVICE --cap-add=NET_RAW -v "$PWD":/etc/envoy/ --name LB2 -t --add-host=host.docker.internal:host-gateway envoyproxy/envoy-dev:448cbd60ee4e1af1f869f9f519095680b233f1e2 > dockerLog.txt 2>&1 &

sleep 3
echo "running OPA"
docker stop OPA
docker rm OPA
docker compose -f docker-compose-http.yaml build
docker compose -f docker-compose-http.yaml up -d
echo "Done!"
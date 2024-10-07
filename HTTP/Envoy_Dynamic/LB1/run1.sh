#!/bin/sh
docker pull envoyproxy/envoy-dev:448cbd60ee4e1af1f869f9f519095680b233f1e2
docker stop LB1
nohup docker run --rm -p 0.0.0.0:10000:10000 -p 0.0.0.0:8002:8002 -v "$PWD"/envoy1.yaml:/etc/envoy/envoy.yaml -v "$PWD"/controller.crt:/etc/envoy/controller.crt --name LB1 -t --add-host=host.docker.internal:host-gateway envoyproxy/envoy-dev:448cbd60ee4e1af1f869f9f519095680b233f1e2 > dockerLog.txt 2>&1 &
echo "Running OPA"

docker stop OPA
docker rm OPA

docker compose -f docker-compose-http.yaml build
docker compose -f docker-compose-http.yaml up -d
echo "Done"
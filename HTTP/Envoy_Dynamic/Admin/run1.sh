#!/bin/bash
echo "Running Webserver"
docker rm Admin
docker rm internalAdmin
docker stop Admin
docker stop internalAdmin

docker compose -f docker-compose.yaml build
docker compose -f docker-compose.yaml up -d
echo "Running Envoy"
docker pull envoyproxy/envoy-dev:448cbd60ee4e1af1f869f9f519095680b233f1e2
nohup docker run --rm -p 0.0.0.0:10000:10000 -p 0.0.0.0:9001:9001 -v "$PWD":/etc/envoy --name Admin -t --add-host=host.docker.internal:host-gateway envoyproxy/envoy-dev:448cbd60ee4e1af1f869f9f519095680b233f1e2 > dockerLog.txt 2>&1 &


echo "Done"

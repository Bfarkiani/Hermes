#!/bin/bash
docker rm IngressNginx
docker compose -f docker-compose.yaml build
docker compose -f docker-compose.yaml up -d
echo "Done"
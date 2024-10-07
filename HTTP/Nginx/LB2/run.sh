#!/bin/bash
docker rm LB2Nginx
docker compose -f docker-compose.yaml build
docker compose -f docker-compose.yaml up -d
echo "Done"
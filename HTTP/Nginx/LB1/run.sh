#!/bin/bash
docker rm LB1Nginx
docker compose -f docker-compose.yaml build
docker compose -f docker-compose.yaml up -d
echo "Done"
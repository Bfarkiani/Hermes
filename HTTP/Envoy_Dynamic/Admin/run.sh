#!/bin/bash
echo "Running Webserver"
docker rm internalAdmin
docker compose -f docker-compose.yaml build
docker compose -f docker-compose.yaml up -d
echo "Done"

#!/bin/bash
echo "killing docker"
sleep 1
docker kill $(docker ps -q)
echo "Done!"
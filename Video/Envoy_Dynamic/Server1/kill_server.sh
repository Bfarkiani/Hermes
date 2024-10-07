#!/bin/bash
id=$(pgrep -f Server.py)
echo "Killing $id"
sleep 1
kill -9 $id
echo "killing docker"
sleep 1
docker kill $(docker ps -q)
echo "Done!"
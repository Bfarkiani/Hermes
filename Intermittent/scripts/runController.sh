#!/bin/bash

if [ $# -ne 1 ]
then
    echo "Usage: $0 <Controller directory>"
    echo "Example: $0 /users2/jdd/IMO/envoystatsdexperiment/envoyControlPlane/Controller_Secure/"
    exit 0
else
    CONTROLLER_DIR=$1
    echo "CONTROLLER_DIR: ${CONTROLLER_DIR}"
fi

# cd ${CONTROLLER_DIR}
# docker load -i ./envoy_controller.tar
# docker run -p 18000:18000 -p 19000:19000 -v "$(pwd)/controller.crt":/controller/controller.crt -v "$(pwd)/controller.key":/controller/controller.key envoy_controller -dbHost=192.168.6.1 -updateTime=10s -dbPort=5984 -dbPassword="123456" -dbUserName="ONL" -dbName="users"


cd ${CONTROLLER_DIR}
FILE=$(find . -type f -name "envoy_controller*.tar" -exec basename {} \;)
docker load -i $FILE
VERSION=$(echo $FILE | sed 's/^.*_\(.*\)\.tar/\1/')

echo "running Controller..."
nohup docker run -p 18000:18000 -p 19000:19000 --name Controller -t -v "$PWD/controller.crt":/controller/controller.crt -v "$PWD/controller.key":/controller/controller.key envoy_controller:$VERSION -dbHost=192.168.6.1 -updateTime=10s -dbPort=5984 -dbPassword="123456" -dbUserName="ONL" -dbName="users" > controllerLog.txt 2>&1 &
echo "Done"
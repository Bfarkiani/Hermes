docker stop Controller
docker rm Controller
FILE=$(find . -type f -name "envoy_controller*.tar" -exec basename {} \;)
#docker image rm IMAGE envoy_controller --force
docker load -i $FILE
VERSION=$(echo $FILE | sed 's/^.*_\(.*\)\.tar/\1/')

echo "running Controller..."
nohup docker run -p 18000:18000 -p 19000:19000 --name Controller -t -v "$PWD/controller.crt":/controller/controller.crt -v "$PWD/controller.key":/controller/controller.key envoy_controller:$VERSION -dbHost=192.168.6.1 -updateTime=10s > controllerLog.txt 2>&1 &
echo "Done"
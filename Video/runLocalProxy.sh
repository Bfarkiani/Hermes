#!/bin/bash


cleanup() {
echo "Cleanup all"
./kill.sh
echo "Done with cleanup"
}
#####################################################


#set -e
trap cleanup EXIT

echo "running Local Envoy"
pushd $PWD/Envoy_Dynamic/Local/
./run.sh 
popd


echo "Background mode loops forever"
while true; do
	:
done

echo "All Done"

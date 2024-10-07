#!/bin/bash
controller(){
echo "Startarting DB ..."
ssh -x "${!Control}" "cd ${DB_DIR} ; ./runDB.sh" &
sleep 30
echo "Running Controller"
ssh -x "${!Control}" "cd ${Controller_DIR} ; ./run.sh" &

}

setup() {

    echo "Starting..."

    echo "Start Ingress"
	echo "Using encrypted connection between local and Ingress"
	ssh -x "${!Ingress}" "cd ${VIDEO_DIR}/Ingress; ./run.sh;" &

    echo "sleep 5"
    sleep 5

    echo "Start LB1"
    ssh -x "${!LB1}" "cd ${VIDEO_DIR}/LB1; ./run.sh;" &
    echo "sleep 5"
    sleep 5
	
	echo "Start LB2"
    ssh -x "${!LB2}" "cd ${VIDEO_DIR}/LB2 ; ./run.sh;" &
    echo "sleep 5"
    sleep 5
	
	echo "Start Server1"
    ssh -x "${!Server1}" "cd ${VIDEO_DIR}/Server1 ; ./run.sh;" &
    echo "sleep 5"
    sleep 5

	echo "Start Server2"
    ssh -x "${!Server2}" "cd ${VIDEO_DIR}/Server2 ; ./run.sh" &
    echo "sleep 5"
    sleep 5
	
	echo "We sleep for 10 more seconds :)"
	sleep 10
	echo "Ok setup is ready"

}


cleanup() {
echo "Cleanup all"
ssh -x "${!Ingress}" "cd $(pwd) ; ./kill.sh" &
sleep 3
ssh -x "${!LB1}" "cd $(pwd) ; ./kill.sh" &
sleep 3
ssh -x "${!LB2}" "cd $(pwd) ; ./kill.sh" &
sleep 3
ssh -x "${!Server1}" "cd $(pwd) ; ./kill_server.sh" &
sleep 3
ssh -x "${!Server2}" "cd $(pwd) ; ./kill_server.sh" &
sleep 5
ssh -x "${!Control}" "cd $(pwd) ; ./kill.sh" &
sleep 10
echo "Done with cleanup"
}
#####################################################

clear
#set -e
trap cleanup EXIT

source /users/bfarkiani/.topology


VIDEO_DIR=$(pwd)/Envoy_Dynamic
Controller_DIR=$(dirname "$PWD")/Controller
DB_DIR=$(pwd)/DB

Ingress="h7x1"
LB1="h9x1"
LB2="h4x1"
Server1="h9x2"
Server2="h4x2"
Control="h6x1"
#0 -> TLS connection between client and Server1. 1-> plain http 
echo "running controller"
controller 
echo "sleeping 30 seconds"
sleep 30   
echo "running Infrastructure setup ..."

setup
echo "Background mode loops forever"
while true; do
	:
done

echo "All Done"

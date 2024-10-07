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
	ssh -x "${!Ingress}" "cd ${MYSQL_DIR}/Ingress; ./run.sh;" &


    echo "sleep 5"
    sleep 5

    echo "Start LB1"
    ssh -x "${!LB1}" "cd ${MYSQL_DIR}/LB1; ./run.sh;" &
    echo "sleep 5"
    sleep 5
	
	echo "Start LB2"
    ssh -x "${!LB2}" "cd ${MYSQL_DIR}/LB2 ; ./run.sh;" &
    echo "sleep 5"
    sleep 5
	
	echo "Start Server1 and generate a random file"
	
    ssh -x "${!Server1}" "cd ${MYSQL_DIR}/Server1 ; ./run.sh;" &
	
    echo "sleep 5"
    sleep 5

	echo "Start Server2 and generate a random file"
    ssh -x "${!Server2}" "cd ${MYSQL_DIR}/Server2 ; ./run.sh" &
    echo "sleep 5"
    sleep 5
	
	echo "MySQL is slow, It needs 3 minutes. So we sleep for 3 minutes:)"
	sleep 180
	echo "Ok setup is ready"

}


cleanup() {
echo "Cleanup all"
ssh -x "${!Ingress}" "cd $(pwd) ; ./kill.sh" &
sleep 3
ssh -x "${!LB1}" "cd $(pwd) ; ./kill.sh" &
sleep 3
ssh -x "${!LB2}" " cd $(pwd) ; ./kill.sh" &
sleep 3
ssh -x "${!Server1}" "cd $(pwd) ; ./kill_server.sh" &
sleep 3
ssh -x "${!Server2}" "cd $(pwd) ; ./kill_server.sh" &
sleep 3
ssh -x "${!Control}" "cd $(pwd) ; ./kill.sh" &
sleep 10

echo "Done with cleanup"
}

#####################################################

clear
#set -e
trap cleanup EXIT

source /users/bfarkiani/.topology
MYSQL_DIR=$(pwd)/Envoy_Dynamic
DB_DIR=$(pwd)/DB
Controller_DIR=$(dirname "$PWD")/Controller
SCRIPTS=$(pwd)

#NGINX_HOST="h1x1"
Ingress="h7x1"
LB1="h9x1"
LB2="h4x1"
Server1="h9x2"
Server2="h4x2"
Control="h6x1"

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

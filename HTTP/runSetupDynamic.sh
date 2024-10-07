#!/bin/bash

controller(){
echo "Startarting DB ..."
ssh -x "${!Control}" "cd ${DB_DIR} ; ./runDB.sh" &
sleep 30
echo "Running Controller"
ssh -x "${!Control}" "cd ${Controller_DIR} ; ./run.sh" &

}


nginX() {

    echo "Start Nginx Setup ..."

    echo "Start Ingress"
    ssh -x "${!Ingress}" "cd ${Nginx_DIR}/Ingress ; ./run.sh" &
    echo "sleep 5"
    sleep 5

    echo "Start LB1"
    ssh -x "${!LB1}" "cd ${Nginx_DIR}/LB1 ; ./run.sh" &
    echo "sleep 5"
    sleep 5
	
	echo "Start LB2"
    ssh -x "${!LB2}" "cd ${Nginx_DIR}/LB2 ; ./run.sh" &
    echo "sleep 5"
    sleep 5
	


}


envoY() {

    echo "Start Envoy Setup ..."

	echo "Using encrypted connection between local and Ingress"
	ssh -x "${!Ingress}" "cd ${Envoy_DIR}/Ingress; ./run.sh;" &

    echo "sleep 5"
    sleep 5


    echo "Start Envoy Setup ..."

	if [ $ServiceMode -eq 0 ]; then
		echo "Servers are not colocated with proxy"
		echo "Start LB1"
		ssh -x "${!LB1}" "cd ${Envoy_DIR}/LB1 ; ./run.sh" &
		echo "sleep 5"
		sleep 5
		
		echo "Start LB2"
		ssh -x "${!LB2}" "cd ${Envoy_DIR}/LB2 ; ./run.sh" &
		echo "sleep 5"
		sleep 5
	else
		echo "Servers are colocated with proxy"
		echo "Start LB1"
		ssh -x "${!LB1}" "cd ${Envoy_DIR}/LB1 ; ./run1.sh" &
		echo "sleep 5"
		sleep 5
		
		echo "Start LB2"
		ssh -x "${!LB2}" "cd ${Envoy_DIR}/LB2 ; ./run1.sh" &
		echo "sleep 5"
		sleep 5
	fi
    echo "sleep 5"
    sleep 5
	
}

serveR(){
	if [ $ServiceMode -eq 0 ]; then
		echo "Servers are not colocated with proxy"
		echo "Start Web1"
		ssh -x "${!Web1}" "cd ${Envoy_DIR}/Web1 ; ./run.sh" &
		echo "sleep 5"
		sleep 5

		echo "Start Web2"
		ssh -x "${!Web2}" "cd ${Envoy_DIR}/Web2 ; ./run.sh" &
		echo "sleep 5"
		sleep 5

		echo "Start Admin"
		ssh -x "${!Admin}" "cd ${Envoy_DIR}/Admin ; ./run.sh" &
		echo "sleep 5"
		sleep 5
		
	else
		echo "Servers are colocated with proxy"
		echo "Start Web1"
		ssh -x "${!Web1}" "cd ${Envoy_DIR}/Web1 ; ./run1.sh" &
		echo "sleep 5"
		sleep 5

		echo "Start Web2"
		ssh -x "${!Web2}" "cd ${Envoy_DIR}/Web2 ; ./run1.sh" &
		echo "sleep 5"
		sleep 5

		echo "Start Admin"
		ssh -x "${!Admin}" "cd ${Envoy_DIR}/Admin ; ./run1.sh" &
		echo "sleep 5"
		sleep 5
	
	fi


}


cleanup() {
echo "Cleanup all"
ssh -x "${!Ingress}" "cd $(pwd) ; ./kill.sh" &
sleep 3
ssh -x "${!LB1}" "cd $(pwd) ; ./kill.sh" &
sleep 3
ssh -x "${!LB2}" "cd $(pwd) ; ./kill.sh" &
sleep 3
ssh -x "${!Web1}" "cd $(pwd) ; ./kill.sh" &
sleep 3
ssh -x "${!Web2}" "cd $(pwd) ; ./kill.sh" &
sleep 3
ssh -x "${!Admin}" "cd $(pwd) ; ./kill.sh" &
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


Nginx_DIR=$(pwd)/Nginx
Envoy_DIR=$(pwd)/Envoy_Dynamic
DB_DIR=$(pwd)/DB
Controller_DIR=$(dirname "$PWD")/Controller
SCRIPTS=$(pwd)

#NGINX_HOST="h1x1"
Ingress="h7x1"
LB1="h9x1"
LB2="h4x1"
Web1="h9x2"
Web2="h4x2"
Admin="h10x1"
Control="h6x1"
#0-> encrypted 1-> Plain
#in Dynamic we do not support clear connection because it was only for tests
#ConnectionMode=${1:-0}     
#0-> Servers are not behind envoy 1-> behind envoy
ServiceMode=${1:-0}   

echo "running controller"
controller 
echo "sleeping 30 seconds"
sleep 30   
echo "running Nginx setup ..."
nginX
echo "running Envoy setup ..."
envoY
echo "running web servers"
serveR

echo "Background mode loops forever"
while true; do
	:
done

echo "All Done"

#!/bin/bash
#Usage: ./runSetup.sh <username> <testname>, such as ./runSetup.sh claire test1
#This script includes 4 tests setup, which are test1, test2, test3, test4
#For test1, it will start nginx
#For test2, it will start nginx and intermittent links
#For test3, it will start CouchDB, Controller, envoy proxy, nginx and intermittent links
#For test4, it will start CouchDB, Controller, envoy proxy, nginx and intermittent links. The difference with test3 is that envoys are not caching

runTest1() {
  echo ""
  echo "Running test1, no Envoy, no intermittent"

  echo "Start nginx"
  ssh -x $NGINX_HOST_MACHINE "cd ${NGINX_DIR} ; ./run-docker.sh >& /tmp/nginx.docker.log" &
  echo "sleep 10"
  sleep 10

  echo "sleep random 0-5 seconds"
  sleep $((RANDOM % 6))

  echo "Retrieve $FILE1"
  ssh -x $CURL_HOST_MACHINE "cd ${PWD} ; ./run_wget_h2_direct.sh $FILE1 $TEST1_FILE1_OUTPUT | tee -a /tmp/test1_1MB.log"

    echo "sleep 5"
    sleep 5
    echo "sleep random 0-5 seconds"
    sleep $((RANDOM % 6))
  echo "Retrieve $FILE1 for the second time"
  ssh -x $CURL_HOST_MACHINE "cd ${PWD} ; ./run_wget_h2_direct.sh $FILE1 $TEST1_FILE1_OUTPUT | tee -a /tmp/test1_1MB.log"
    echo "sleep 5"
    sleep 5
    echo "sleep random 0-5 seconds"
    sleep $((RANDOM % 6))	

  echo "Retrieve $FILE2"
  ssh -x $CURL_HOST_MACHINE "cd ${PWD} ; ./run_wget_h2_direct.sh $FILE2 $TEST1_FILE2_OUTPUT | tee -a /tmp/test1_5MB.log"
  echo "Retrieve $FILE2 for the second time"
  ssh -x $CURL_HOST_MACHINE "cd ${PWD} ; ./run_wget_h2_direct.sh $FILE2 $TEST1_FILE2_OUTPUT | tee -a /tmp/test1_5MB.log"

}

runTest2() {
  echo ""
  echo "Running test2, no Envoy, with intermittent"

  echo "Start nginx"
  ssh -x $NGINX_HOST_MACHINE "cd ${NGINX_DIR} ; ./run-docker.sh >& /tmp/nginx.docker.log" &
  echo "sleep 10"
  sleep 10

  echo "Turning on intermittent links"
  time=$(date +%H:%M:%S)

  ./run_drop_loss_otel2.py -u $USERNAME -ut 1 -d 0 -l 0 >& ./run_drop_loss.log &

  echo "sleep 5"
  sleep 5

  echo "sleep random 0-5 seconds"
  sleep $((RANDOM % 6))

  echo "Retrieve $FILE1"
  ssh -x $CURL_HOST_MACHINE "cd ${PWD} ; ./run_wget_h2_direct.sh $FILE1 $TEST2_FILE1_OUTPUT | tee -a /tmp/test2_1MB.log"

  echo "sleep random 0-5 seconds"
  sleep $((RANDOM % 6))

  echo "Retrieve $FILE2"
  ssh -x $CURL_HOST_MACHINE "cd ${PWD} ; ./run_wget_h2_direct.sh $FILE2 $TEST2_FILE2_OUTPUT | tee -a /tmp/test2_5MB.log"
}

runTest3() {
    echo ""
    echo "Running test3, with Envoy, with caching, with intermittent"

    # Run local proxy
    echo "Start local proxy"
    ssh -x $LOCAL_PROXY_HOST_MACHINE "cd ${LOCAL_PROXY_DIR_CACHE} ; ./runLocalProxy.sh >& /tmp/runLocalProxy.log" &
    echo "sleep 10"
    sleep 10

    # Run CouchDB
    echo "Start CounchDB"
    COUCHDB_CONFIGS_DIR=$(pwd)/../couchdb/Cache
    ssh -x $STATS_HOST_MACHINE "cd ${PWD} ; ./runCouchDB.sh ${COUCHDB_CONFIGS_DIR} >& /tmp/couchdb.log" &
    echo "sleep 10"
    sleep 10

    # Run Controller
    echo "Start Envoy Controller"
    ssh -x $STATS_HOST_MACHINE "cd ${PWD} ; ./runController.sh ${CONTROLLER_DIR} >& /tmp/controller.log" &
    echo "sleep 10"
    sleep 10

    echo "Start Envoy"
    pushd ${ENVOY_DIR} >& /dev/null
    ./runONL.sh $USERNAME >& ./envoy.log
    popd >& /dev/null
    echo "sleep 20"
    sleep 20


    # This appears to be the place we need to sleep for things to settle.
    # After a reboot it can take over 10 seconds for the docker process to come up and
    # get configured. Later re-runs seem to take more like 5-6 seconds. 
    # so, we just have to make sure we give them time.
    echo "sleep 20 to give envoys time to get going before starting drop loss"
    sleep 20
    
    echo "Start nginx"
    ssh -x $NGINX_HOST_MACHINE "cd ${NGINX_DIR} ; ./run-docker.sh >& /tmp/nginx.docker.log" &
    echo "sleep 5"
    sleep 5

    echo "Turning on intermittent links"
    time=$(date +%H:%M:%S)

    ./run_drop_loss_otel2.py -u $USERNAME -ut 1 -d 0 -l 0 >& ./run_drop_loss.log &

    echo "sleep 5"
    sleep 5
    echo "sleep random 0-5 seconds"
    sleep $((RANDOM % 6))

    echo "Retrieve $FILE1"
    ssh -x $CURL_HOST_MACHINE "cd ${PWD} ; ./run_wget_h2.sh $FILE1 $TEST3_FILE1_OUTPUT | tee -a /tmp/test3_1MB.log"
    echo "sleep 5"
    sleep 5
    echo "sleep random 0-5 seconds"
    sleep $((RANDOM % 6))
    echo "Retrieve $FILE1 for the second time"
    ssh -x $CURL_HOST_MACHINE "cd ${PWD} ; ./run_wget_h2.sh $FILE1 $TEST3_FILE1_OUTPUT | tee -a /tmp/test3_1MB.log"

    echo "sleep 5"
    sleep 5
    echo "sleep random 0-5 seconds"
    sleep $((RANDOM % 6))

    echo "Retrieve $FILE2"
    ssh -x $CURL_HOST_MACHINE "cd ${PWD} ; ./run_wget_h2.sh $FILE2 $TEST3_FILE2_OUTPUT | tee -a /tmp/test3_5MB.log"
    echo "sleep 5"
    sleep 5
    echo "sleep random 0-5 seconds"
    sleep $((RANDOM % 6))
    echo "Retrieve $FILE2 for the second time"
    ssh -x $CURL_HOST_MACHINE "cd ${PWD} ; ./run_wget_h2.sh $FILE2 $TEST3_FILE2_OUTPUT | tee -a /tmp/test3_5MB.log"

}

runTest4() {
    echo ""
    echo "Running test4, with Envoy, without caching, with intermittent"

    # Run local proxy
    echo "Start local proxy"
    ssh -x $LOCAL_PROXY_HOST_MACHINE "cd ${LOCAL_PROXY_DIR_NOCACHE} ; ./runLocalProxy.sh >& /tmp/runLocalProxy.log" &
    echo "sleep 10"
    sleep 10

    # Run CouchDB
    echo "Start CounchDB"
    COUCHDB_CONFIGS_DIR=$(pwd)/../couchdb/Nocache
    ssh -x $STATS_HOST_MACHINE "cd ${PWD} ; ./runCouchDB.sh ${COUCHDB_CONFIGS_DIR} >& /tmp/couchdb.log" &
    echo "sleep 10"
    sleep 10

    # Run Controller
    echo "Start Envoy Controller"
    ssh -x $STATS_HOST_MACHINE "cd ${PWD} ; ./runController.sh ${CONTROLLER_DIR} >& /tmp/controller.log" &
    echo "sleep 10"
    sleep 10

    echo "Start Envoy"
    pushd ${ENVOY_DIR} >& /dev/null
    ./runONL.sh $USERNAME >& ./envoy.log
    popd >& /dev/null
    echo "sleep 20"
    sleep 20

    # This appears to be the place we need to sleep for things to settle.
    # After a reboot it can take over 10 seconds for the docker process to come up and
    # get configured. Later re-runs seem to take more like 5-6 seconds. 
    # so, we just have to make sure we give them time.
    echo "sleep 20 to give envoys time to get going before starting drop loss"
    sleep 20
    
    echo "Start nginx"
    ssh -x $NGINX_HOST_MACHINE "cd ${NGINX_DIR} ; ./run-docker.sh >& /tmp/nginx.docker.log" &
    echo "sleep 5"
    sleep 5

    echo "Turning on intermittent links"
    time=$(date +%H:%M:%S)

    ./run_drop_loss_otel2.py -u $USERNAME -ut 1 -d 0 -l 0 >& ./run_drop_loss.log &

    echo "sleep 5"
    sleep 5
    echo "sleep random 0-5 seconds"
    sleep $((RANDOM % 6))

    echo "Retrieve $FILE1"
    ssh -x $CURL_HOST_MACHINE "cd ${PWD} ; ./run_wget_h2_connect.sh $FILE1 $TEST4_FILE1_OUTPUT | tee -a /tmp/test4_1MB.log"
    echo "sleep 5"
    sleep 5
    echo "sleep random 0-5 seconds"
    sleep $((RANDOM % 6))
    echo "Retrieve $FILE1 for the second time"
    ssh -x $CURL_HOST_MACHINE "cd ${PWD} ; ./run_wget_h2_connect.sh $FILE1 $TEST4_FILE1_OUTPUT | tee -a /tmp/test4_1MB.log"

    echo "sleep 5"
    sleep 5
    echo "sleep random 0-5 seconds"
    sleep $((RANDOM % 6))

    echo "Retrieve $FILE2"
    ssh -x $CURL_HOST_MACHINE "cd ${PWD} ; ./run_wget_h2_connect.sh $FILE2 $TEST4_FILE2_OUTPUT | tee -a /tmp/test4_5MB.log"
    echo "sleep 5"
    sleep 5
	echo "sleep random 0-5 seconds"
    sleep $((RANDOM % 6))
    echo "Retrieve $FILE2 for the second time"
    ssh -x $CURL_HOST_MACHINE "cd ${PWD} ; ./run_wget_h2_connect.sh $FILE2 $TEST4_FILE2_OUTPUT | tee -a /tmp/test4_5MB.log"

}

cleanup() {
    echo ""
    echo "Cleanup all"
    killall run_drop_loss_otel2.py
    ./reset_links.sh $USERNAME 0 0 >& /dev/null
    ./stopAllDocker.sh $USERNAME
    echo "Done with cleanup"
}


#####################################################

clear
if [ $# -ne 1 ]
then
  echo "Usage: $0 <username>"
  exit 0
fi
trap cleanup EXIT

echo "LOGNAME: $LOGNAME"
ORIGNAME=$LOGNAME
LOGNAME=$1
USERNAME=$1

echo "LOGNAME: $LOGNAME"
source /users/$LOGNAME/.topology

PWD=$(pwd)
echo "PWD: $PWD"
ENVOY_DIR=$(pwd)/../envoy_static
LOCAL_PROXY_DIR_NOCACHE=$(pwd)/../envoy_static/run_local_proxy_nocache
LOCAL_PROXY_DIR_CACHE=$(pwd)/../envoy_static/run_local_proxy_cache
CONTROLLER_DIR=$(pwd)/../controller
NGINX_DIR=$(pwd)/../nginx
SCRIPTS=$(pwd)

NGINX_HOST="h5x1"
STATS_HOST="h6x1"
CONTROLLER_HOST="h6x1"
LOCAL_PROXY_HOST="h8x1"
CURL_HOST="h8x1"
eval NGINX_HOST_MACHINE=\$$NGINX_HOST
eval STATS_HOST_MACHINE=\$$STATS_HOST  
eval LOCAL_PROXY_HOST_MACHINE=\$$LOCAL_PROXY_HOST
eval CURL_HOST_MACHINE=\$$CURL_HOST

# TEST=$2
# # Use a case statement to determine which test function to call
# case "$2" in
#     "test1")
#         runTest1
#         ;;
#     "test2")
#         runTest2
#         ;;
#     "test3")
#         runTest3
#         ;;
#     "test4")
#         runTest4
#         ;;
#     *)
#         echo "Invalid function name: $2"
#         exit 1
#         ;;
# esac

# echo "all configured."
# echo "hit return when ready to cleanup and exit"
# read response

# cleanup

# echo "All Done"

FILE1="1mb.txt"  
FILE2="5mb.txt"
TEST1_FILE1_OUTPUT="N_N_N_FILE1.txt"
TEST1_FILE2_OUTPUT="N_N_N_FILE2.txt"
TEST2_FILE1_OUTPUT="N_N_Y_FILE1.txt"
TEST2_FILE2_OUTPUT="N_N_Y_FILE2.txt"
TEST3_FILE1_OUTPUT="Y_Y_Y_FILE1.txt"
TEST3_FILE2_OUTPUT="Y_Y_Y_FILE2.txt"
TEST4_FILE1_OUTPUT="Y_N_Y_FILE1.txt"
TEST4_FILE2_OUTPUT="Y_N_Y_FILE2.txt"

rm -f $TEST1_FILE1_OUTPUT
rm -f $TEST1_FILE2_OUTPUT
rm -f $TEST2_FILE1_OUTPUT
rm -f $TEST2_FILE2_OUTPUT
rm -f $TEST3_FILE1_OUTPUT
rm -f $TEST3_FILE2_OUTPUT
rm -f $TEST4_FILE1_OUTPUT
rm -f $TEST4_FILE2_OUTPUT

for ((i=1; i<=5; i++)); do
  echo "*********Loop: $i****************"
  cleanup
  runTest1
  cleanup
  runTest2
  cleanup
  runTest3
  cleanup
  runTest4
  cleanup
done

echo "All Done"


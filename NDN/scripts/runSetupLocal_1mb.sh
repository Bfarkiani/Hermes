#!/bin/bash


runSetup() {
    echo ""

#    echo "copy tracing configurations to current dir"
#    cp ${COUCHDB_DIR}/../${ENVOY_CFGS}/*yaml ${COUCHDB_DIR}/

    # Run CouchDB
    echo "Start CounchDB"
    ssh -x $STATS_HOST_MACHINE "cd ${COUCHDB_DIR} ; ./runDB.sh ${COUCHDB_DIR} >& /tmp/couchdb.log" &
    echo "sleep 5"
    sleep 5

    # Run Controller
    echo "Start Envoy Controller"
    ssh -x $STATS_HOST_MACHINE "cd ${CONTROLLER_DIR} ; ./run.sh ${CONTROLLER_DIR} >& /tmp/controller.log" &
    echo "sleep 5"
    sleep 5

    echo "Start Envoy"
    pushd ${ENVOY_DIR} >& /dev/null
    #./runONL.sh $USERNAME $STATS_SINK >& /dev/null
    ./runONL.sh $USERNAME $STATS_SINK >& /tmp/runEnvoy.log
    popd >& /dev/null
    echo "sleep 5"
    sleep 5


    echo "Start stats"
    #if [ $STATS_SINK -ne 0 ]
    #then
    #    ssh -x $STATS_HOST_MACHINE "cd ${SCRIPTS} ; ./run_otel_collector.sh " &
    #fi
    ssh -x $STATS_HOST_MACHINE "cd ${SCRIPTS} ; ./run_all_stats.sh ${STATS_SINK} >& /tmp/stats.log" &
    echo "sleep 5"
    sleep 5

    # This appears to be the place we need to sleep for things to settle.
    # After a reboot it can take over 10 seconds for the docker process to come up and
    # get configured. Later re-runs seem to take more like 5-6 seconds. 
    # so, we just have to make sure we give them time.
    echo "sleep 5 to give stats and envoys time to get going before starting NDN"
    sleep 5
    
     # Run and Config nfds
     echo "Start nfds"
     pushd ${NDN_DIR}
     ./runNfd.sh $USERNAME ${NDN_DIR} >& /tmp/runNfd.log
     echo "sleep 5"
     sleep 5
     ./configNfd.sh $USERNAME ${NDN_DIR} >& /tmp/configNfd.log
     popd

     # Run ndnputchunks
     echo "Start ndnputchunks"
     pushd ${NDN_DIR}
     ./run_putChunks_onl.sh $USERNAME ${NDN_DIR} /onl ${FILEPATH} ${RESULTS_FILE} >& /tmp/run_putChunks_onl.log &
     ./run_putChunks_arl.sh $USERNAME ${NDN_DIR} /arl ${FILEPATH} ${RESULTS_FILE} >& /tmp/run_putChunks_arl.log &

     echo "sleep 5"
     sleep 5
     popd

     ## Run ndncatchunks
     #echo "Start ndncatchunks"
     #pushd ${NDN_DIR}
     #./run_catChunks_fixed.sh $USERNAME ${NDN_DIR} ${NDNNAME} ${OUTPUT_FILE} ${RESULTS_FILE} ${PIPELINE_MAX} >& /tmp/run_catChunks.log 
     #popd


     
}

cleanup() {
echo "Cleanup all"
#killall drop_loss_alternate_from_onlusr.sh
#killall -q run_drop_loss_prom.py
#killall -q run_drop_loss_otel2.py
./reset_links.sh $USERNAME 0 $LOSS>& /dev/null
./stopAllDocker.sh $USERNAME
#./stopAllEnvoy.sh $USERNAME
./stopNfd.sh $USERNAME
ssh -x $STATS_HOST_MACHINE "killall prometheus; killall jaeger-all-in-one; killall otelcol-jp"
echo "Done with cleanup"
}
#####################################################

clear
#if [ $# -ne 6 ]
#then
#  echo "Usage: $0 <username> <ndn name> <file path> <output file> <results file> <pipeline max>"
#  exit 0
#fi
#echo "LOGNAME: $LOGNAME"
#ORIGNAME=$LOGNAME
#LOGNAME=$1
#USERNAME=$1
#NDNNAME=$2
#FILEPATH=$3
#OUTPUT_FILE=$4
#RESULTS_FILE=$5
#PIPELINE_MAX=$6
#
PWD=$(pwd)
USERNAME=${1:-"bfarkiani"}
INPUT_FILE=1mb.txt
NDNNAMEONL=/onl
NDNNAMEARL=/arl

FILEPATH=${PWD}/../testFiles/${INPUT_FILE}
OUTPUT_FILE=/tmp/${INPUT_FILE}
RESULTS_FILE=${PWD}/RESULTS/${INPUT_FILE}.results
PIPELINE_MAX=20


source /users/$USERNAME/.topology
SLEEP_TIME=10
STATS_SINK=1

PWD=$(pwd)
echo "PWD: $PWD"
ENVOY_DIR=$(pwd)/../envoy_static
NDN_DIR=$(pwd)/../ndn

COUCHDB_DIR=$(pwd)/../DB
CONTROLLER_DIR=$(pwd)/../Controller
SCRIPTS=$(pwd)

STATS_HOST="h6x1"
CONTROLLER_HOST="h6x1"
eval STATS_HOST_MACHINE=\$$STATS_HOST
    

cleanup

echo "USERNAME: $USERNAME"
runSetup

echo "Setup Done"


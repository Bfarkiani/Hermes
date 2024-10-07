#!/bin/bash

runTest() {

     # Run ndncatchunks
     echo "Start ndncatchunks"
     pushd ${NDN_DIR}
     echo "run catchunk onl"
	 ./run_catChunks_fixed_onl.sh $USERNAME ${NDN_DIR} ${NDNNAME_ONL} ${OUTPUT_FILE} ${RESULTS_FILE_ONL} ${PIPELINE_MAX} >& /tmp/run_catChunks_onl.log 
	 sleep 5
	 echo "run catchunk arl"
	 ./run_catChunks_fixed_arl.sh $USERNAME ${NDN_DIR} ${NDNNAME_ARL} ${OUTPUT_FILE} ${RESULTS_FILE_ARL} ${PIPELINE_MAX} >& /tmp/run_catChunks_arl.log 
	 sleep 5
     popd


     
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
NDNNAME_ONL=/onl
NDNNAME_ARL=/arl

OUTPUT_FILE=/tmp/${INPUT_FILE}
PIPELINE_MAX=20

da=$(date +%H-%M-%S)
source /users/$USERNAME/.topology
SLEEP_TIME=10
STATS_SINK=1

PWD=$(pwd)
echo "PWD: $PWD"
NDN_DIR=$(pwd)/../ndn

SCRIPTS=$(pwd)

#curl -o RESULTS/IngressProxyEnvoyStatsPrerun.txt http://${h7x1}:9001/stats
#curl -o RESULTS/NdnClientEnvoyStatsPrerun.txt http://${h13x1}:9001/stats
#curl -o RESULTS/NdnServerEnvoyStatsPrerun.txt http://${h8x1}:9001/stats

echo "Running Tests"
sleep 20

d=$(date +%H-%M-%S)
RESULTS_FILE_ONL=${PWD}/RESULTS/${INPUT_FILE}_ONL_1mb_${d}
RESULTS_FILE_ARL=${PWD}/RESULTS/${INPUT_FILE}_ARL_1mb_${d}

runTest

sleep 5 

echo "sleeping 30seconds"
sleep 30

echo "running again"
d=$(date +%H-%M-%S)
RESULTS_FILE_ONL=${PWD}/RESULTS/${INPUT_FILE}_ONL_1mb_${d}
RESULTS_FILE_ARL=${PWD}/RESULTS/${INPUT_FILE}_ARL_1mb_${d}

runTest

sleep 60 

#curl -o RESULTS/IngressProxyEnvoyStatsPostrun.txt http://${h7x1}:9001/stats
#curl -o RESULTS/NdnClientEnvoyStatsPostrun.txt http://${h13x1}:9001/stats
#curl -o RESULTS/NdnServerEnvoyStatsPostrun.txt http://${h8x1}:9001/stats

#echo "Test done. Hit return when ready to tear down"
#read response

cleanup

echo "Test Done and torn down"


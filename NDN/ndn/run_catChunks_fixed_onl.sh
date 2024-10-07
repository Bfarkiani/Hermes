#! /bin/bash

if [ $# -lt 6 ]
then
  echo "Usage: $0 <username> <NDN directory> <NDN-Name> <Output file> <Results file> <pipeline max>"
  exit 0
fi
echo "LOGNAME: $LOGNAME"
ORIGNAME=$LOGNAME
LOGNAME=$1
USERNAME=$1
NDN_DIR=$2
NDNNAME=$3
OUTPUT_FILE=$4
RESULTS_FILE=$5
PIPELINE_MAX=$6
echo "LOGNAME: $LOGNAME"
source /users/$LOGNAME/.topology
ENVOY_DIR=$(pwd)

HOSTS=( h14x1 )
for HST in "${HOSTS[@]}"
do
	eval HST_MACHINE=\$$HST
	echo "ssh -x $HST_MACHINE cd ${NDN_DIR}/${HST}; ./run_ndncatchunks_fixed.sh  ${NDNNAME} ${OUTPUT_FILE} ${RESULTS_FILE} ${PIPELINE_MAX} "
	ssh -x $HST_MACHINE "cd ${NDN_DIR}/${HST}; ./run_ndncatchunks_fixed.sh $NDNNAME ${OUTPUT_FILE} ${RESULTS_FILE} ${PIPELINE_MAX} "
done

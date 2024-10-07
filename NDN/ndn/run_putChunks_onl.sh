#! /bin/bash


if [ $# -lt 5 ]
then
  echo "Usage: $0 <username> <NDN Directory> NDN-Name File-path <Results file>"
  exit 0
fi
echo "LOGNAME: $LOGNAME"
ORIGNAME=$LOGNAME
LOGNAME=$1
USERNAME=$1
NDN_DIR=$2
NDNNAME=$3
FILEPATH=$4
RESULTS_FILE=$5
echo "LOGNAME: $LOGNAME"
source /users/$LOGNAME/.topology
ENVOY_DIR=$(pwd)

HOSTS=( h9x1 h9x2)
for HST in "${HOSTS[@]}"
do
	eval HST_MACHINE=\$$HST
	echo "ssh -x $HST_MACHINE cd ${NDN_DIR}/${HST}; ./run_ndnputchunks.sh  $NDNNAME $FILEPATH"
	ssh -x $HST_MACHINE "cd ${NDN_DIR}/${HST}; ./run_ndnputchunks.sh  $NDNNAME $FILEPATH ${RESULTS_FILE}"
done

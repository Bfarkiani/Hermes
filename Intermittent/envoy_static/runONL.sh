#! /bin/bash


if [ $# -lt 1 ]
then
  echo "Usage: $0 <username> "
  exit 0
fi
echo "LOGNAME: $LOGNAME"
ORIGNAME=$LOGNAME
LOGNAME=$1
USERNAME=$1
STAT_SINK=0
if [ $# -gt 1 ]
then
	STAT_SINK=$2
fi
echo "LOGNAME: $LOGNAME"
source /users/$LOGNAME/.topology
ENVOY_DIR=$(pwd)

HOSTS=( h7x1 h5x1 h13x1 h14x1 h15x1 h6x1)
for HST in "${HOSTS[@]}"
do
	eval HST_MACHINE=\$$HST
	echo "ssh -x $HST_MACHINE cd ${ENVOY_DIR}/run_${HST}; ./run-envoy-docker-ONL.sh $STAT_SINK"
	ssh -x $HST_MACHINE "cd ${ENVOY_DIR}/run_${HST}; ./run-envoy-docker-ONL.sh $STAT_SINK" &

done

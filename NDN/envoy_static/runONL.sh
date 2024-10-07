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

HOSTS=( h13x1 h7x1 h8x1 h4x1 h4x2 h9x1 h9x2)
for HST in "${HOSTS[@]}"
do
	eval HST_MACHINE=\$$HST
	echo "ssh -x $HST_MACHINE cd ${ENVOY_DIR}/${HST}; ./run.sh $STAT_SINK"
	ssh -x $HST_MACHINE "cd ${ENVOY_DIR}/${HST}; ./run.sh $STAT_SINK" &
sleep 5
done

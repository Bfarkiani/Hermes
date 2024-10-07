#! /bin/bash


if [ $# -lt 2 ]
then
  echo "Usage: $0 <username> <ndn directory>"
  exit 0
fi
echo "LOGNAME: $LOGNAME"
ORIGNAME=$LOGNAME
LOGNAME=$1
USERNAME=$1
NDN_DIR=$2
echo "LOGNAME: $LOGNAME"
source /users/$LOGNAME/.topology
ENVOY_DIR=$(pwd)

HOSTS=( h14x1 h4x1 h4x2 h9x1 h9x2 )
for HST in "${HOSTS[@]}"
do
	eval HST_MACHINE=\$$HST
	echo "ssh -x $HST_MACHINE cd ${NDN_DIR}/${HST}; ./config_nfd_direct.sh "
	ssh -x $HST_MACHINE "cd ${NDN_DIR}/${HST}; ./config_nfd_direct.sh "
done

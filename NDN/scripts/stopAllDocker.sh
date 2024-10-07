#! /bin/bash


if [ $# -lt 1 ]
then
  echo "Usage: $0 <username> "
  exit 0
fi
#echo "LOGNAME: $LOGNAME"
ORIGNAME=$LOGNAME
LOGNAME=$1
USERNAME=$1
#echo "LOGNAME: $LOGNAME"
source /users/$LOGNAME/.topology
SCRIPTS=$(pwd)

HOSTS=( h6x1 h7x1 h8x1 h13x1 h14x1 h4x1 h4x2 h9x1 h9x2)
for HST in "${HOSTS[@]}"
do
	eval HST_MACHINE=\$$HST
	echo "ssh -x $HST_MACHINE cd ${SCRIPTS} ; ./stopAllDockerOnHost.sh"
	ssh -x $HST_MACHINE "cd ${SCRIPTS}; ./stopAllDockerOnHost.sh"
done


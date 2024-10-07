#! /bin/bash


if [ $# -lt 1 ]
then
  echo "Usage: $0 <username> "
  exit 0
fi

ORIGNAME=$LOGNAME
LOGNAME=$1
USERNAME=$1
source /users/$LOGNAME/.topology
SCRIPTS=$(pwd)

HOSTS=( h5x1 h13x1 h14x1 h15x1 h6x1 h7x1 h8x1)
for HST in "${HOSTS[@]}"
do
	eval HST_MACHINE=\$$HST
	echo "ssh -x $HST_MACHINE cd ${SCRIPTS} ; ./stopAllDockerOnHost.sh"
	ssh -x $HST_MACHINE "cd ${SCRIPTS}; ./stopAllDockerOnHost.sh"
done


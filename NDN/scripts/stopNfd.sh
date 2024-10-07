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

HOSTS=( h13x1 h8x1 h4x1 h4x2 h9x1 h9x2 h14x1)
for HST in "${HOSTS[@]}"
do
	eval HST_MACHINE=\$$HST
	echo "ssh -x $HST_MACHINE nfd-stop"
	ssh -x $HST_MACHINE "killall nfd"
done


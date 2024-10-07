#!/bin/bash

if [ $# -lt 1 ]
then
  echo "Usage: $0 <username> [delay loss]"
  echo "  resets links to delay loss"
  exit 0
fi
UNAME=$1
BASE_DIR="/users/onl/swr/scripts"
DELAY=0
LOSS=0
NUMLINKS=3 #2 #3 1

echo "sudo ${BASE_DIR}/reset_links_from_onlusr.sh $UNAME $DELAY $LOSS $NUMLINKS"
sudo ${BASE_DIR}/reset_links_from_onlusr.sh $UNAME $DELAY $LOSS $NUMLINKS


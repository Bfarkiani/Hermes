#!/bin/bash


if [ $# != 3 ]
then
    echo "Usage: $0 <ndn name> <filename> <results file>"
    echo "Example: $0 ndn:/ndn/testfiles/constitution.txt testFiles/constitution.txt /tmp/results.log"
    exit 0
fi
NDN_NAME=$1
FILE=$2
RESULTS_FILE=$3

MAX_CHUNK_SIZE=8000

#cat ${FILE}  | ndnputchunks ${NDN_NAME} 2>> ${RESULTS_FILE}
#ndnputchunks ${NDN_NAME} < ${FILE} 2>> ${RESULTS_FILE}
ndnputchunks /arl < ${FILE} > putchunk_Log.txt 2>&1 & 

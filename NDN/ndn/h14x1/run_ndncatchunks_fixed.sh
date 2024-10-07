#!/bin/bash

if [ $# != 4 ]
then
    echo "Usage: $0 <ndn name> <output file> <collection of results file> <pipeline max"
    echo "Example: $0 ndn:/testfiles/constitution.txt 1"
    exit 0
fi
NDN_NAME=$1
OUTPUT_FILE=$2
RESULTS_FILE=$3
PIPELINE_MAX=$4

# Fixed pipeline

echo "ndncatchunks -f -p fixed -s ${PIPELINE_MAX}  ${NDN_NAME}  ${OUTPUT_FILE}"
echo "in ndncatchunk"
ndncatchunks -f -p fixed -s ${PIPELINE_MAX}  ${NDN_NAME} >& ${OUTPUT_FILE}

# Cubic pipeline
#ndncatchunks -p cubic ${NDN_NAME} >& ${OUTPUT_FILE}

# AIMD pipeline
#ndncatchunks -p aimd ${NDN_NAME} >& ${OUTPUT_FILE}

#tail -11 ${OUTPUT_FILE} >> ${RESULTS_FILE}
echo "doing tail"
tail -6 ${OUTPUT_FILE} >> ${RESULTS_FILE}

exit 0
#!/bin/bash
FNM=$1
OUTPUT=$2

rm -f OUTPUT
for ((i=1; i<=1; i++)); do

    echo "Iteration $i"
    rm -f ${FILE}.out

    echo "curl -k -m 900 --connect-timeout 900 -o ${FNM}.out -w  \"@curl-format\"  https://192.168.5.1:8443/unstable/${FNM}"
    curl -k -m 900 --connect-timeout 900 -o ${FNM}.out -w "%{time_total}\n" https://192.168.5.1:8443/unstable/${FNM} >> $OUTPUT

    return=$?
    if [ $return -ne 0 ]; then
    echo "ERROR: return code:$return for above" >> $OUTPUT
    fi
    
done
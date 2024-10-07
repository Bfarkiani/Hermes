#!/bin/bash
FNM=$1
OUTPUT=$2

rm -f OUTPUT
for ((i=1; i<=1; i++)); do

    echo "Iteration $i"
    rm -f ${FILE}.out
    echo "curl -m 900 --connect-timeout 900 -o ${FNM}.out -w "%{time_total}\n" -k http://onl/unstable/${FNM} -x http://127.0.0.1:12000 >> $OUTPUT"
    curl -m 900 --connect-timeout 900 -o ${FNM}.out -w "%{time_total}\n" -k http://onl/unstable/${FNM} -x http://127.0.0.1:12000 >> $OUTPUT
    return=$?
    if [ $return -ne 0 ]; then
    echo "ERROR: return code:$return for above" >> $OUTPUT
    fi 
    
done

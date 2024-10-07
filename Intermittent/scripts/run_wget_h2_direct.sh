#!/bin/bash
FNM=$1
OUTPUT=$2
rm -f ${FNM}.out

for ((i=1; i<=1; i++)); do

    echo "Iteration $i"
    rm -f ${FNM}.out
	echo "wget --tries=10 --waitretry=10 --timeout=30 --continue http://onl/unstable/${FNM} -x http://127.0.0.1:12000"  | tee -a $OUTPUT
	/usr/bin/time --format "${i}\t%e real,\t%U user,\t%S sys" -a -o $OUTPUT wget --retry-connrefused --retry-on-http-error=503 --output-document=${FNM}.out --tries=10 --waitretry=20 --timeout=60 --continue --header="Host: random_$i" --no-check-certificate https://192.168.5.1:8443/unstable/${FNM} | tee -a $OUTPUT

    return=$?
    if [ $return -ne 0 ]; then
    echo "ERROR: return code:$return for above" | tee -a $OUTPUT
    fi 
    
done
rm -f ${FNM}.out

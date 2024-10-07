#!/bin/bash
FNM=$1
OUTPUT=$2
rm -f ${FNM}.out

for ((i=1; i<=1; i++)); do

    echo "Iteration $i"
    rm -f ${FNM}.out
	echo "wget --tries=10 --waitretry=10 --timeout=30 --continue http://onl/unstable/${FNM} -x http://127.0.0.1:12000"  tee -a $OUTPUT
	/usr/bin/time --format "${i}\t%e real,\t%U user,\t%S sys" -a -o $OUTPUT wget --output-document=${FNM}.out --retry-on-http-error=503 --tries=10 --waitretry=20 --timeout=60 --continue --retry-connrefused --header="Host: random_$i" -e use_proxy=yes -e http_proxy=127.0.0.1:12000 -e https_proxy=127.0.0.1:12000 --no-check-certificate https://onl/unstable/${FNM} | tee -a $OUTPUT

    return=$?
    if [ $return -ne 0 ]; then
    echo "ERROR: return code:$return for above" | tee -a $OUTPUT
    fi 
    
done
rm -f ${FNM}.out

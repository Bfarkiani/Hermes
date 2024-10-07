#!/bin/bash
SLEEP_TIME=10

cleanup() {
echo "Cleanup all"
sleep 3
docker kill Local
sleep 5
echo "Done with cleanup"
}

#file that we donwload ->data1 or data25
#FNM=${1:-data1}
#number of iterations
Iteration=${1:-5}
#output logfile
OUT=${2:-runtimeProxy}
#this is VPN IP address of local host
REMOTEIP=${3:-"192.168.252.20"}
#this is local envoy listening port
REMOTEPORT=${4:-"10000"}
#0->Envoy 1->TCP
counter=0 

trap cleanup EXIT
echo "running Local Envoy"
pushd $PWD/Envoy_Dynamic/Local/ 
./run.sh 
popd 
echo "sleeping 20 seconds to get dynamic configuration"
sleep 20

time=$(date +%H-%M-%S)
rm -f STATUS.txt

for i in $( seq 1 $Iteration )
do
	echo "downloading 0mb file..."
	rm -f 0mb.sql 
	sleep 3
	counter=$((counter + 1))
	FNM=data0
	OUTPUT=Envoy_F0_${time}
	/usr/bin/time --format "${i}\t%E real,\t%U user,\t%S sys" -a -o $OUTPUT.txt mysqldump --max_allowed_packet=512M  --routines=true -u root -p'123' -h $REMOTEIP -P $REMOTEPORT test $FNM  > 0mb.sql
	size=$(stat -c%s 0mb.sql)

	if [ $size -gt 1950 ] && [ $size -lt 2000 ]; then
		echo "Successful proxy downlaod of 0mb at Iteration $counter" | tee -a STATUS.txt
	else
		echo "Failed proxy downlaod of 0mb at Iteration $counter" | tee -a STATUS.txt
	fi
	
	echo "Sleep $SLEEP_TIME...."
	sleep $SLEEP_TIME
done

echo "..............................."
echo "				Done!            "
echo "..............................."
echo "Testing direct connection speed to 192.168.9.2"

#Requesting from 192.168.9.2
counter=0
#this is VPN IP address of local host
REMOTEIP="192.168.9.2"
#this is local envoy listening port
REMOTEPORT="3306"

for i in $( seq 1 $Iteration )
do
	echo "downloading 25mb file..."
	rm -f 0mb.sql  
	sleep 3
	counter=$((counter + 1))
	FNM=data0
	OUTPUT=9_F0_${time}
	/usr/bin/time --format "${i}\t%E real,\t%U user,\t%S sys" -a -o $OUTPUT.txt mysqldump --max_allowed_packet=512M  --routines=true -u root -p'123' -h $REMOTEIP -P $REMOTEPORT test $FNM  > 0mb.sql
	size=$(stat -c%s 0mb.sql)

	if [ $size -gt 1950 ] && [ $size -lt 2000 ]; then
		echo "Successful 9.2 downlaod of 0mb at Iteration $counter" | tee -a STATUS.txt
	else
		echo "Failed 9.2 downlaod of 0mb at Iteration $counter" | tee -a STATUS.txt
	fi

	echo "Sleep $SLEEP_TIME...."
	sleep $SLEEP_TIME
done

echo "..............................."
echo "				Done!            "
echo "..............................."
echo "Testing direct connection speed to 192.168.4.2"

#Requesting from 192.168.9.2
counter=0
#this is VPN IP address of local host
REMOTEIP="192.168.4.2"
#this is local envoy listening port
REMOTEPORT="3306"

for i in $( seq 1 $Iteration )
do
	echo "downloading 25mb file..."
	rm -f 0mb.sql
	sleep 3
	counter=$((counter + 1))
	FNM=data0
	OUTPUT=4_F0_${time}
	/usr/bin/time --format "${i}\t%E real,\t%U user,\t%S sys" -a -o $OUTPUT.txt mysqldump --max_allowed_packet=512M  --routines=true -u root -p'123' -h $REMOTEIP -P $REMOTEPORT test $FNM  > 0mb.sql
	size=$(stat -c%s 0mb.sql)

	if [ $size -gt 1950 ] && [ $size -lt 2000 ]; then
		echo "Successful 4.2 downlaod of 0mb at Iteration $counter" | tee -a STATUS.txt
	else
		echo "Failed 4.2 downlaod of 0mb at Iteration $counter" | tee -a STATUS.txt
	fi

	echo "Sleep $SLEEP_TIME...."
	sleep $SLEEP_TIME
done


echo "Background mode loops forever"
while true; do
	:
done

echo "All Done!"
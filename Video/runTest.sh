#!/bin/bash
SLEEP_TIME=5

DATA(){
cp $PWD/Envoy_Dynamic/Ingress/dockerLog.txt $PWD/ingress_dockerLog_${time}.txt
cp $PWD/Envoy_Dynamic/LB1/dockerLog.txt $PWD/LB1_dockerLog_${time}.txt
cp $PWD/Envoy_Dynamic/LB2/dockerLog.txt $PWD/LB2_dockerLog_${time}.txt
cp $PWD/Envoy_Dynamic/Server1/dockerLog.txt $PWD/Server1_dockerLog_${time}.txt
cp $PWD/Envoy_Dynamic/Server2/dockerLog.txt $PWD/Server2_dockerLog_${time}.txt
cp $PWD/Envoy_Dynamic/Server2/dockerLog.txt $PWD/Server2_dockerLog_${time}.txt
cp $PWD/Envoy_Dynamic/Server2/serverLog.txt $PWD/server2Log_${time}.txt
cp $PWD/Envoy_Dynamic/Server1/serverLog.txt $PWD/server1Log_${time}.txt
echo "sleep 3"
echo "Killing Local Docker!"
$PWD/kill.sh
sleep 3
echo "Done with DATA"

}

cleanup() {
echo "Killing Local Docker!"
$PWD/kill.sh
sleep 3

echo "Done with Cleaning"
}

#file that we donwload ->data1 or data25
#FNM=${1:-data1}
#number of iterations
Iteration=${1:-5}
#output logfile
OUT=${2:-runtimeProxy}
#this is VPN IP address of local host
REMOTEIP=${3:-"127.0.0.1"}
#this is local envoy listening port
REMOTEPORT=${4:-"10000"}
#0->Envoy 1->TCP
counter=0 
time=$(date +%H-%M-%S)
trap cleanup EXIT
echo "running Local Envoy"
pushd $PWD/Envoy_Dynamic/Local/ 
./run.sh 
popd 
echo "sleeping 10 seconds to get dynamic configuration"
sleep 10

for i in $( seq 1 $Iteration )
do
	echo "Iteration $i for Envoy"
	echo "recording 1 minute video file with 90s timeout..."
	rm -f output*.mp4
	sleep $SLEEP_TIME
	FNM=data25
	OUTPUT=Envoy_F1_${i}_${time}
	echo "	curl --header \"Token: user\" -i http://onl/org/video/percy1.mp4 -x http://$REMOTEIP:$REMOTEPORT; ffmpeg -analyzeduration 2147483647 -probesize 2147483647 -err_detect ignore_err -fflags +genpts -rtbufsize 40M -i \"udp://localhost:4444?buffer_size=26214400&timeout=90000000&fifo_size=500000?reuse=1\" -c copy -y output1.mp4 2>&1 "
	curl --header "Token: user" -i http://onl/org/video/percy1.mp4 -x http://$REMOTEIP:$REMOTEPORT; ffmpeg -analyzeduration 2147483647 -probesize 2147483647 -err_detect ignore_err -fflags +genpts -rtbufsize 40M -i "udp://localhost:4444?buffer_size=26214400&timeout=90000000&fifo_size=500000?reuse=1" -c copy -y output1.mp4 2>&1 | tee -a log_${time}.txt
	echo "Analyzing..."
	ffmpeg -v error -i output1.mp4 -f null - 2>&1 | tee -a $OUTPUT.txt	
	sleep 3
	size=$(stat -c%s output1.mp4)

	if [ $size -gt 5600000  ]; then
		echo "Successful proxy downlaod of percy1 at Iteration $i" | tee -a STATUS_${time}.txt
	else
		echo "Failed proxy downlaod of percy1 at Iteration $i" | tee -a STATUS_${time}.txt
	fi

	echo "sleep for $SLEEP_TIME seconds"
	sleep $SLEEP_TIME
	echo "recording 2 minute video file with 150s timeout..."
	FNM=data25
	OUTPUT=Envoy_F2_${i}_${time}
	echo "	curl --header \"Token: user\" -i http://onl/org/video/percy2.mp4 -x http://$REMOTEIP:$REMOTEPORT; ffmpeg -analyzeduration 2147483647 -probesize 2147483647 -err_detect ignore_err -fflags +genpts -rtbufsize 40M -i \"udp://localhost:4444?buffer_size=26214400&timeout=150000000&fifo_size=500000?reuse=1\" -c copy -y output2.mp4 2>&1 "
	curl --header "Token: user" -i http://onl/org/video/percy2.mp4 -x http://$REMOTEIP:$REMOTEPORT; ffmpeg -analyzeduration 2147483647 -probesize 2147483647 -err_detect ignore_err -fflags +genpts -rtbufsize 40M -i "udp://localhost:4444?buffer_size=26214400&timeout=150000000&fifo_size=500000?reuse=1" -c copy -y output2.mp4 2>&1 | tee -a log_${time}.txt
	echo "Analyzing..."
	ffmpeg -v error -i output2.mp4 -f null - 2>&1 | tee -a $OUTPUT.txt
	sleep 3
	size=$(stat -c%s output2.mp4)

	if [ $size -gt 11000000   ]; then
		echo "Successful proxy downlaod of percy2 at Iteration $i" | tee -a STATUS_${time}.txt
	else
		echo "Failed proxy downlaod of percy2 at Iteration $i" | tee -a STATUS_${time}.txt
	fi

	echo "Sleep $SLEEP_TIME...."
	sleep $SLEEP_TIME
done

echo "..............................."
echo "				Done!            "
echo "..............................."
echo "Testing direct connection from video server 9.2"

#Requesting from 192.168.9.2
counter=0
#this is VPN IP address of local host
REMOTEIP="192.168.9.2"
#this is local envoy listening port
REMOTEPORT="8888"

for i in $( seq 1 $Iteration )
do
	echo "Iteration $i for 9.2"

	echo "recording 1 minute video file with 90s timeout..."
	rm -f output*.mp4
	sleep $SLEEP_TIME
	OUTPUT=Direct9_F1_${i}_${time}
	echo "	curl --header \"Token: user\" -i http://$REMOTEIP:$REMOTEPORT/percy1.mp4; ffmpeg -analyzeduration 2147483647 -probesize 2147483647 -err_detect ignore_err -fflags +genpts -rtbufsize 40M -i \"udp://@192.168.9.2:7000?buffer_size=26214400&timeout=90000000&fifo_size=500000?reuse=1\" -c copy -y output1.mp4 2>&1 "
	curl --header "Token: user" -i http://$REMOTEIP:$REMOTEPORT/percy1.mp4; ffmpeg -analyzeduration 2147483647 -probesize 2147483647 -err_detect ignore_err -fflags +genpts -rtbufsize 40M -i "udp://@192.168.9.2:7000?buffer_size=26214400&timeout=90000000&fifo_size=500000?reuse=1" -c copy -y output1.mp4 2>&1 | tee -a log_${time}.txt
	echo "Analyzing..."
	ffmpeg -v error -i output1.mp4 -f null - 2>&1 | tee -a $OUTPUT.txt	
	sleep 3
	size=$(stat -c%s output1.mp4)

	if [ $size -gt 5600000  ]; then
		echo "Successful 9.2 downlaod of percy1 at Iteration $i" | tee -a STATUS_${time}.txt
	else
		echo "Failed 9.2 downlaod of percy1 at Iteration $i" | tee -a STATUS_${time}.txt
	fi
	echo "recording 2 minute video file with 150s timeout..."
	sleep $SLEEP_TIME
	FNM=data25
	OUTPUT=Direct9_F2_${i}_${time}
	echo "	curl --header \"Token: user\" -i http://$REMOTEIP:$REMOTEPORT/percy2.mp4; ffmpeg -analyzeduration 2147483647 -probesize 2147483647 -err_detect ignore_err -fflags +genpts -rtbufsize 40M -i \"udp://192.168.9.2:7000?buffer_size=26214400&timeout=150000000&fifo_size=500000?reuse=1\" -c copy -y output2.mp4 2>&1 "
	curl --header "Token: user" -i http://$REMOTEIP:$REMOTEPORT/percy2.mp4; ffmpeg -analyzeduration 2147483647 -probesize 2147483647 -err_detect ignore_err -fflags +genpts -rtbufsize 40M -i "udp://@192.168.9.2:7000?buffer_size=26214400&timeout=150000000&fifo_size=500000?reuse=1" -c copy -y output2.mp4 2>&1 | tee -a log_${time}.txt
	echo "Analyzing..."
	ffmpeg -v error -i output2.mp4 -f null - 2>&1 | tee -a $OUTPUT.txt
	sleep 3
	size=$(stat -c%s output2.mp4)

	if [ $size -gt 11000000   ]; then
		echo "Successful 9.2 downlaod of percy2 at Iteration $i" | tee -a STATUS_${time}.txt
	else
		echo "Failed 9.2 downlaod of percy2 at Iteration $i" | tee -a STATUS_${time}.txt
	fi
	echo "Sleep $SLEEP_TIME...."
	sleep $SLEEP_TIME
done


echo "..............................."
echo "				Done!            "
echo "..............................."
echo "Testing direct connection from video server 4.2"

#Requesting from 192.168.4.2
counter=0
#this is VPN IP address of local host
REMOTEIP="192.168.4.2"
#this is local envoy listening port
REMOTEPORT="8888"

for i in $( seq 1 $Iteration )
do
	echo "Iteration $i for 4.2"

	echo "recording 1 minute video file with 90s timeout..."
	rm -f output*.mp4
	sleep $SLEEP_TIME
	OUTPUT=Direct4_F1_${i}_${time}
	echo "	curl --header \"Token: user\" -i http://$REMOTEIP:$REMOTEPORT/percy1.mp4; ffmpeg -analyzeduration 2147483647 -probesize 2147483647 -err_detect ignore_err -fflags +genpts -rtbufsize 40M -i \"udp://@192.168.4.2:7000?buffer_size=26214400&timeout=90000000&fifo_size=500000?reuse=1\" -c copy -y output1.mp4 2>&1 "
	curl --header "Token: user" -i http://$REMOTEIP:$REMOTEPORT/percy1.mp4; ffmpeg -analyzeduration 2147483647 -probesize 2147483647 -err_detect ignore_err -fflags +genpts -rtbufsize 40M -i "udp://@192.168.4.2:7000?buffer_size=26214400&timeout=90000000&fifo_size=500000?reuse=1" -c copy -y output1.mp4 2>&1 | tee -a log_${time}.txt
	echo "Analyzing..."
	ffmpeg -v error -i output1.mp4 -f null - 2>&1 | tee -a $OUTPUT.txt	
	sleep 3
	size=$(stat -c%s output1.mp4)

	if [ $size -gt 5600000  ]; then
		echo "Successful 4.2 downlaod of percy1 at Iteration $i" | tee -a STATUS_${time}.txt
	else
		echo "Failed 4.2 downlaod of percy1 at Iteration $i" | tee -a STATUS_${time}.txt
	fi
	
	echo "recording 2 minute video file with 150s timeout..."
	sleep $SLEEP_TIME
	FNM=data25
	OUTPUT=Direct4_F2_${i}_${time}
	echo "	curl --header \"Token: user\" -i http://$REMOTEIP:$REMOTEPORT/percy2.mp4; ffmpeg -analyzeduration 2147483647 -probesize 2147483647 -err_detect ignore_err -fflags +genpts -rtbufsize 40M -i \"udp://192.168.4.2:7000?buffer_size=26214400&timeout=150000000&fifo_size=500000?reuse=1\" -c copy -y output2.mp4 2>&1 "
	curl --header "Token: user" -i http://$REMOTEIP:$REMOTEPORT/percy2.mp4; ffmpeg -analyzeduration 2147483647 -probesize 2147483647 -err_detect ignore_err -fflags +genpts -rtbufsize 40M -i "udp://@192.168.4.2:7000?buffer_size=26214400&timeout=150000000&fifo_size=500000?reuse=1" -c copy -y output2.mp4 2>&1 | tee -a log_${time}.txt
	echo "Analyzing..."
	ffmpeg -v error -i output2.mp4 -f null - 2>&1 | tee -a $OUTPUT.txt
	sleep 3
	size=$(stat -c%s output2.mp4)

	if [ $size -gt 11000000   ]; then
		echo "Successful 4.2 downlaod of percy2 at Iteration $i" | tee -a STATUS_${time}.txt
	else
		echo "Failed 4.2 downlaod of percy2 at Iteration $i" | tee -a STATUS_${time}.txt
	fi
	echo "Sleep $SLEEP_TIME...."
	sleep $SLEEP_TIME
done


DATA

echo "Background mode loops forever"
while true; do
	:
done
echo "All Done"

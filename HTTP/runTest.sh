#!/bin/bash
SLEEP_TIME=10

#file that we donwload
#FNM=${1:-1mb.txt}
#number of iterations
Iteration=${1:-5}
#output logfile
#OUT=${2:-out}
REMOTEIP=${2:-"127.0.0.1"}
#this is local envoy listening port
REMOTEPORT=${3:-"12000"}
#0->Envoy 1->TCP
#Mode=${4:-1}
#0->normal user 1-> admin
#USER=${5:-0}
counter=0 

echo "First Envoy!"

time=$(date +%H-%M-%S)

for i in $( seq 1 $Iteration )
do
	rm -f 25mb.epub 1mb.txt 50mb.txt
	
	sleep 3
	counter=$((counter + 1))
	echo "Iteration: $i"

	FNM=1mb

	OUTPUT=Envoy_${time}
	echo "downloading 1mb file..."
	echo "curl -m 900 --connect-timeout 900 -o ${FNM}.out --header \"Token: user\" -i -k http://onl/org/web/files/${FNM}.txt -x http://127.0.0.1:12000 " 
	curl -m 900 --connect-timeout 900 -o ${FNM}.txt -w "1mbUser\t$counter\thttp_code\t%{http_code}\tStart\t%{time_starttransfer}\tTotal\t%{time_total}\n" --header "Token: user" -k http://onl/org/web/files/${FNM}.txt -x http://127.0.0.1:12000 | tee -a $OUTPUT

	echo "curl -m 900 --connect-timeout 900 -o ${FNM}.out --header \"Token: admin\" -i -k http://onl/org/web/files/${FNM}.txt -x http://127.0.0.1:12000 " 
	curl -m 900 --connect-timeout 900 -o ${FNM}.txt -w "1mbAdmin1\t$counter\thttp_code\t%{http_code}\tStart\t%{time_starttransfer}\tTotal\t%{time_total}\n" --header "Token: admin" -k http://onl/org/web/files/${FNM}.txt -x http://127.0.0.1:12000 | tee -a $OUTPUT

	echo "curl -m 900 --connect-timeout 900 -o ${FNM}.out --header \"Token: admin\" -i -k http://onl/org/admin/files/${FNM}.txt -x http://127.0.0.1:12000 " 
	curl -m 900 --connect-timeout 900 -o ${FNM}.txt -w "1mbAdmin2\t$counter\thttp_code\t%{http_code}\tStart\t%{time_starttransfer}\tTotal\t%{time_total}\n" --header "Token: admin" -k http://onl/org/admin/files/${FNM}.txt -x http://127.0.0.1:12000 | tee -a $OUTPUT



	FNM=25mb
	echo "downloading 25mb file..."

	echo "curl -m 900 --connect-timeout 900 -o ${FNM}.out --header \"Token: user\" -i -k http://onl/org/web/files/${FNM}.epub -x http://127.0.0.1:12000 " 
	curl -m 900 --connect-timeout 900 -o ${FNM}.epub -w "25mbUser\t$counter\thttp_code\t%{http_code}\tStart\t%{time_starttransfer}\tTotal\t%{time_total}\n" --header "Token: user" -k http://onl/org/web/files/${FNM}.epub -x http://127.0.0.1:12000 | tee -a $OUTPUT

	echo "curl -m 900 --connect-timeout 900 -o ${FNM}.out --header \"Token: admin\" -i -k http://onl/org/web/files/${FNM}.epub -x http://127.0.0.1:12000 " 
	curl -m 900 --connect-timeout 900 -o ${FNM}.epub -w "25mbAdmin1\t$counter\thttp_code\t%{http_code}\tStart\t%{time_starttransfer}\tTotal\t%{time_total}\n" --header "Token: admin" -k http://onl/org/web/files/${FNM}.epub -x http://127.0.0.1:12000 | tee -a $OUTPUT

	echo "curl -m 900 --connect-timeout 900 -o ${FNM}.out --header \"Token: admin\" -i -k http://onl/org/admin/files/${FNM}.epub -x http://127.0.0.1:12000 " 
	curl -m 900 --connect-timeout 900 -o ${FNM}.epub -w "25mbAdmin2\t$counter\thttp_code\t%{http_code}\tStart\t%{time_starttransfer}\tTotal\t%{time_total}\n" --header "Token: admin" -k http://onl/org/admin/files/${FNM}.epub -x http://127.0.0.1:12000 | tee -a $OUTPUT

	FNM=50mb
	echo "downloading 50mb file..."

	echo "curl -m 900 --connect-timeout 900 -o ${FNM}.txt --header \"Token: user\" -i -k http://onl/org/web/files/${FNM}.txt -x http://127.0.0.1:12000 " 
	curl -m 900 --connect-timeout 900 -o ${FNM}.txt -w "50mbUser\t$counter\thttp_code\t%{http_code}\tStart\t%{time_starttransfer}\tTotal\t%{time_total}\n" --header "Token: user" -k http://onl/org/web/files/${FNM}.txt -x http://127.0.0.1:12000 | tee -a $OUTPUT

	echo "curl -m 900 --connect-timeout 900 -o ${FNM}.txt --header \"Token: admin\" -i -k http://onl/org/web/files/${FNM}.txt -x http://127.0.0.1:12000" 
	curl -m 900 --connect-timeout 900 -o ${FNM}.txt -w "50mbAdmin1\t$counter\thttp_code\t%{http_code}\tStart\t%{time_starttransfer}\tTotal\t%{time_total}\n" --header "Token: admin" -k http://onl/org/web/files/${FNM}.txt -x http://127.0.0.1:12000 | tee -a $OUTPUT

	echo "curl -m 900 --connect-timeout 900 -o ${FNM}.txt --header \"Token: admin\" -i -k http://onl/org/admin/files/${FNM}.txt -x http://127.0.0.1:12000 " 
	curl -m 900 --connect-timeout 900 -o ${FNM}.txt -w "50mbAdmin2\t$counter\thttp_code\t%{http_code}\tStart\t%{time_starttransfer}\tTotal\t%{time_total}\n" --header "Token: admin" -k http://onl/org/admin/files/${FNM}.txt -x http://127.0.0.1:12000 | tee -a $OUTPUT

	echo "Sleep $SLEEP_TIME...."
	sleep $SLEEP_TIME
done

echo "..............................."
echo "				Done!            "
echo "..............................."
echo "Testing Nginx"
counter=0

for i in $( seq 1 $Iteration )
do
	rm -f 25mb.epub 1mb.txt 50mb.txt
	sleep 3
	counter=$((counter + 1))
	FNM=1mb
	echo "Iteration: $i"

	OUTPUT=Nginx_${time}
	echo "downloading 1mb file..."

	echo "curl -m 900 --connect-timeout 900 -o ${FNM}.txt --header \"Token: user\" --header \"Host: onl\" -i -k https://192.168.7.1:10001/org/web/files/${FNM}.txt"  
	curl -m 900 --connect-timeout 900 -o ${FNM}.txt -w "1mbUser\t$counter\thttp_code\t%{http_code}\tStart\t%{time_starttransfer}\tTotal\t%{time_total}\n" --header "Token: user" --header "Host: onl" -k https://192.168.7.1:10001/org/web/files/${FNM}.txt | tee -a $OUTPUT

	echo "curl -m 900 --connect-timeout 900 -o ${FNM}.txt --header \"Token: admin\" --header \"Host: onl\" -i -k https://192.168.7.1:10001/org/web/files/${FNM}.txt"  
	curl -m 900 --connect-timeout 900 -o ${FNM}.txt -w "1mbAdmin1\t$counter\thttp_code\t%{http_code}\tStart\t%{time_starttransfer}\tTotal\t%{time_total}\n" --header "Token: admin" --header "Host: onl" -k https://192.168.7.1:10001/org/web/files/${FNM}.txt | tee -a $OUTPUT

	echo "curl -m 900 --connect-timeout 900 -o ${FNM}.txt --header \"Token: admin\" --header \"Host: onl\" -i -k https://192.168.7.1:10001/org/admin/files/${FNM}.txt"  
	curl -m 900 --connect-timeout 900 -o ${FNM}.txt -w "1mbAdmin2\t$counter\thttp_code\t%{http_code}\tStart\t%{time_starttransfer}\tTotal\t%{time_total}\n" --header "Token: admin" --header "Host: onl" -k https://192.168.7.1:10001/org/admin/files/${FNM}.txt | tee -a $OUTPUT


	FNM=25mb
	echo "downloading 25mb file..."

	echo "curl -m 900 --connect-timeout 900 -o ${FNM}.epub --header \"Token: user\" --header \"Host: onl\" -i -k https://192.168.7.1:10001/org/web/files/${FNM}.epub"  
	curl -m 900 --connect-timeout 900 -o ${FNM}.epub -w "25mbUser\t$counter\thttp_code\t%{http_code}\tStart\t%{time_starttransfer}\tTotal\t%{time_total}\n" --header "Token: user" --header "Host: onl" -k https://192.168.7.1:10001/org/web/files/${FNM}.epub | tee -a $OUTPUT

	echo "curl --connect-timeout 900 -m 900 -o ${FNM}.epub --header \"Token: admin\" --header \"Host: onl\" -i -k https://192.168.7.1:10001/org/web/files/${FNM}.epub"  
	curl -m 900 --connect-timeout 900 -o ${FNM}.epub -w "25mbAdmin1\t$counter\thttp_code\t%{http_code}\tStart\t%{time_starttransfer}\tTotal\t%{time_total}\n" --header "Token: admin" --header "Host: onl" -k https://192.168.7.1:10001/org/web/files/${FNM}.epub | tee -a $OUTPUT

	echo "curl --connect-timeout 900 -m 900 -o ${FNM}.epub --header \"Token: admin\" --header \"Host: onl\" -i -k https://192.168.7.1:10001/org/admin/files/${FNM}.epub"  
	curl -m 900 --connect-timeout 900 -o ${FNM}.epub -w "25mbAdmin2\t$counter\thttp_code\t%{http_code}\tStart\t%{time_starttransfer}\tTotal\t%{time_total}\n" --header "Token: admin" --header "Host: onl" -k https://192.168.7.1:10001/org/admin/files/${FNM}.epub | tee -a $OUTPUT


	FNM=50mb
	echo "downloading 50mb file..."

	echo "curl -m 900 --connect-timeout 900 -o ${FNM}.txt --header \"Token: user\" --header \"Host: onl\" -i -k https://192.168.7.1:10001/org/web/files/${FNM}.txt"  
	curl -m 900 --connect-timeout 900 -o ${FNM}.txt -w "50mbUser\t$counter\thttp_code\t%{http_code}\tStart\t%{time_starttransfer}\tTotal\t%{time_total}\n" --header "Token: user" --header "Host: onl" -k https://192.168.7.1:10001/org/web/files/${FNM}.txt | tee -a $OUTPUT

	echo "curl --connect-timeout 900 -m 900 -o ${FNM}.txt --header \"Token: admin\" --header \"Host: onl\" -i -k https://192.168.7.1:10001/org/web/files/${FNM}.txt"  
	curl -m 900 --connect-timeout 900 -o ${FNM}.txt -w "50mbAdmin1\t$counter\thttp_code\t%{http_code}\tStart\t%{time_starttransfer}\tTotal\t%{time_total}\n" --header "Token: admin" --header "Host: onl" -k https://192.168.7.1:10001/org/web/files/${FNM}.txt | tee -a $OUTPUT

	echo "curl --connect-timeout 900 -m 900 -o ${FNM}.txt --header \"Token: admin\" --header \"Host: onl\" -i -k https://192.168.7.1:10001/org/admin/files/${FNM}.txt"  
	curl -m 900 --connect-timeout 900 -o ${FNM}.txt -w "50mbAdmin2\t$counter\thttp_code\t%{http_code}\tStart\t%{time_starttransfer}\tTotal\t%{time_total}\n" --header "Token: admin" --header "Host: onl" -k https://192.168.7.1:10001/org/admin/files/${FNM}.txt | tee -a $OUTPUT

	echo "Sleep $SLEEP_TIME...."
	sleep $SLEEP_TIME
done


echo "All Done!"
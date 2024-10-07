#!/bin/bash
#Usage: ./runTest.sh <testname>. The test name can be test1, test2, test3, test4.
#For every test, it will retrieve file1, then sleep for 10 seconds, then retrieve file2. Every retrieve will iterate 20 times.
#For the test3 and test4, it will setup local proxy first then retrieve files.


runTest1() {
  echo "\nRunning test1 no envoy, no caching, no intermittent\n"

  echo "Retrieve $FILE1"
  ./run_wget_h2_direct.sh $FILE1 N_N_N_45KB_${time}

  echo "sleep 10"
  sleep 10

  echo "Retrieve $FILE2"
  ./run_wget_h2_direct.sh $FILE2 N_N_N_500KB_${time}
}

runTest2() {
  echo "Running test2 no envoy, no caching, with intermittent"
  t=$((1 + $RANDOM % 10))
  
  echo "sleeping for $t"
  sleep $t
  echo "Retrieve $FILE1"
  ./run_wget_h2_direct.sh $FILE1 N_N_Y_45KB_${time}

  echo "sleep 10"
  sleep 10

  echo "Retrieve $FILE2"
  ./run_wget_h2_direct.sh $FILE2 N_N_Y_500KB_${time}
}

runTest3() {
  echo "Running test3 with envoy, with caching, with intermittent"
  t=$((1 + $RANDOM % 10))
  
  echo "sleeping for $t"
  sleep $t

  # Run local proxy with caching
  echo "Run local proxy with caching"
  cd ${LOCAL_PROXY_DIR_CACHE} ; ./runLocalProxy.sh >& /tmp/runLocalProxy.log
  echo "sleep 10"
  sleep 10

  cd ../../scripts/
  
  echo "Retrieve $FILE1"
  ./run_wget_h2.sh $FILE1 Y_Y_Y_45KB_${time}

  echo "sleep 10"
  sleep 10

  echo "Retrieve $FILE2"
  ./run_wget_h2.sh $FILE2 Y_Y_Y_500KB_${time}

  #Clean up local proxy
  docker stop Local

  echo "sleep 5"
  sleep 5
}

runTest4() {
  echo "Running test4 with envoy, without caching, with intermittent"

  # Run local proxy without caching
  echo "Run local proxy without caching"
  cd ${LOCAL_PROXY_DIR_NOCACHE} ; ./runLocalProxy.sh >& /tmp/runLocalProxy.log
  echo "sleep 10"
  sleep 10

  cd ../../scripts/

  echo "Retrieve $FILE1"
  ./run_wget_h2.sh $FILE1 Y_N_Y_45KB_${time}

  echo "sleep 10"
  sleep 10

  echo "Retrieve $FILE2"
  ./run_wget_h2.sh $FILE2 Y_N_Y_500KB_${time}

  #Clean up local proxy
  docker stop Local

  echo "sleep 5"
  sleep 5
}

if [ $# -ne 1 ]
then
  echo "Usage: $0 <test> "
  exit 0
fi
time=$(date +%H-%M-%S)

FILE1="constitution-45KB.txt"  
FILE2="500KB.epub"
LOCAL_PROXY_DIR_NOCACHE=$(pwd)/../envoy_static/run_local_proxy_nocache
LOCAL_PROXY_DIR_CACHE=$(pwd)/../envoy_static/run_local_proxy_cache

TEST=$1
# Use a case statement to determine which test function to call
case "$1" in
    "test1")
        runTest1
        ;;
    "test2")
        runTest2
        ;;
    "test3")
        runTest3
        ;;
    "test4")
        runTest4
        ;;
    *)
        echo "Invalid function name: $1"
        exit 1
        ;;
esac

echo "All Done"
echo "hit return when ready to cleanup and exit"
read response
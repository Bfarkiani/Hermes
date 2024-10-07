#!/bin/bash

NUM_TESTS=20

USERNAME=${1:-"bfarkiani"}
NDNNAME_ONL=/onl
NDNNAME_ARL=/arl
NDN_DIR=$(pwd)/../ndn
OUTPUT_FILE=/tmp/${INPUT_FILE}

source /users/$LOGNAME/.topology
cleanup() {
echo "Cleanup all"
./reset_links.sh $USERNAME 0 $LOSS>& /dev/null
./stopAllDocker.sh $USERNAME
./stopNfd.sh $USERNAME
ps auxwww | grep bfarkiani | grep put | awk '{print $2}' | xargs kill -9
ps auxwww | grep bfarkiani | grep CoNEXT | awk '{print $2}' | xargs kill -9

echo "Done with cleanup"
sleep 3
}

trap cleanup EXIT

HST_MACHINE=h14x1

i=1
    while [ $i -le $NUM_TESTS ]
    do
        echo "Iteration #$i"
        echo ""
	<< ////
		echo "min file at Iteration #$i"
		
        ./runSetupLocal_min.sh
		sleep 3
		RESULTS_FILE_ONL=${PWD}/RESULTS/ONL_min_${i}
		RESULTS_FILE_ARL=${PWD}/RESULTS/ARL_min_${i}
		OUTPUT_FILE=${PWD}/o_min_${i}
		
		echo "ssh for onl "
		ssh -x $h14x1 "cd ${NDN_DIR}/h14x1; ./run_ndncatchunks_fixed.sh /onl ${OUTPUT_FILE} ${RESULTS_FILE_ONL} 1"
		echo "sleep 5"	
		sleep 5
		
		echo "ssh for arl "
		ssh -x $h14x1 "cd ${NDN_DIR}/h14x1; ./run_ndncatchunks_fixed.sh /arl ${OUTPUT_FILE} ${RESULTS_FILE_ARL} 1"
		echo "sleep 5"	
		sleep 5
		
		echo "running again - min"
		RESULTS_FILE_ONL=${PWD}/RESULTS/ONL_min_${i}_2
		RESULTS_FILE_ARL=${PWD}/RESULTS/ARL_min_${i}_2
		OUTPUT_FILE=${PWD}/o_min_${i}_2	

		echo "ssh for onl "
		ssh -x $h14x1 "cd ${NDN_DIR}/h14x1; ./run_ndncatchunks_fixed.sh /onl ${OUTPUT_FILE} ${RESULTS_FILE_ONL} 1"
		echo "sleep 5"	
		sleep 5
		
		echo "ssh for arl "
		ssh -x $h14x1 "cd ${NDN_DIR}/h14x1; ./run_ndncatchunks_fixed.sh /arl ${OUTPUT_FILE} ${RESULTS_FILE_ARL} 1"
		echo "sleep 5"	
		sleep 5
		
		cleanup


	
#################


		echo "1mb file at Iteration #$i "
    
        ./runSetupLocal_1mb.sh
		sleep 3

		RESULTS_FILE_ONL=${PWD}/RESULTS/ONL_1mb_${i}
		RESULTS_FILE_ARL=${PWD}/RESULTS/ARL_1mb_${i}
		OUTPUT_FILE=${PWD}/o_1mb_${i}
		
		echo "ssh for onl "
		ssh -x $h14x1 "cd ${NDN_DIR}/h14x1; ./run_ndncatchunks_fixed.sh /onl ${OUTPUT_FILE} ${RESULTS_FILE_ONL} 20"
		echo "sleep 5"	
		sleep 5
		
		echo "ssh for arl "
		ssh -x $h14x1 "cd ${NDN_DIR}/h14x1; ./run_ndncatchunks_fixed.sh /arl ${OUTPUT_FILE} ${RESULTS_FILE_ARL} 20"
		echo "sleep 5"	
		sleep 5
		
		echo "running again - 1mb"
		RESULTS_FILE_ONL=${PWD}/RESULTS/ONL_1mb_${i}_2
		RESULTS_FILE_ARL=${PWD}/RESULTS/ARL_1mb_${i}_2
		OUTPUT_FILE=${PWD}/o_1mb_${i}_2	

		echo "ssh for onl "
		ssh -x $h14x1 "cd ${NDN_DIR}/h14x1; ./run_ndncatchunks_fixed.sh /onl ${OUTPUT_FILE} ${RESULTS_FILE_ONL} 20"
		echo "sleep 5"	
		sleep 5
		
		echo "ssh for arl "
		ssh -x $h14x1 "cd ${NDN_DIR}/h14x1; ./run_ndncatchunks_fixed.sh /arl ${OUTPUT_FILE} ${RESULTS_FILE_ARL} 20"
		echo "sleep 5"	
		sleep 5
		
		cleanup

####################

		sleep 10
		echo "25mb file at Iteration #$i"
    
        ./runSetupLocal_25mb.sh
		sleep 3		
		RESULTS_FILE_ONL=${PWD}/RESULTS/ONL_25mb_${i}
		RESULTS_FILE_ARL=${PWD}/RESULTS/ARL_25mb_${i}
		OUTPUT_FILE=${PWD}/o_25mb_${i}
		
		echo "ssh for onl "
		ssh -x $h14x1 "cd ${NDN_DIR}/h14x1; ./run_ndncatchunks_fixed.sh /onl ${OUTPUT_FILE} ${RESULTS_FILE_ONL} 20"
		echo "sleep 30"	
		sleep 30
		
		echo "ssh for arl "
		ssh -x $h14x1 "cd ${NDN_DIR}/h14x1; ./run_ndncatchunks_fixed.sh /arl ${OUTPUT_FILE} ${RESULTS_FILE_ARL} 20"
		echo "sleep 30"	
		sleep 30
		
		echo "running again - 25mb"
		RESULTS_FILE_ONL=${PWD}/RESULTS/ONL_25mb_${i}_2
		RESULTS_FILE_ARL=${PWD}/RESULTS/ARL_25mb_${i}_2
		OUTPUT_FILE=${PWD}/o_25mb_${i}_2		

		echo "ssh for onl "
		ssh -x $h14x1 "cd ${NDN_DIR}/h14x1; ./run_ndncatchunks_fixed.sh /onl ${OUTPUT_FILE} ${RESULTS_FILE_ONL} 20"
		echo "sleep 30"	
		sleep 30
		
		echo "ssh for arl "
		ssh -x $h14x1 "cd ${NDN_DIR}/h14x1; ./run_ndncatchunks_fixed.sh /arl ${OUTPUT_FILE} ${RESULTS_FILE_ARL} 20"
		echo "sleep 30"	
		sleep 30
		
		
		cleanup

########################


////
		sleep 10   
		echo "50mb file at Iteration #$i"    
    
        ./runSetupLocal_50mb.sh
		sleep 3
		RESULTS_FILE_ONL=${PWD}/RESULTS/ONL_50mb_${i}
		RESULTS_FILE_ARL=${PWD}/RESULTS/ARL_50mb_${i}
		OUTPUT_FILE=${PWD}/o_50mb_${i}
		echo "sleep 60"
		sleep 60
		echo "ssh for onl "
		ssh -x $h14x1 "cd ${NDN_DIR}/h14x1; ./run_ndncatchunks_fixed.sh /onl ${OUTPUT_FILE} ${RESULTS_FILE_ONL} 20"
		echo "sleep 60"	
		sleep 60
		
		echo "ssh for arl "
		ssh -x $h14x1 "cd ${NDN_DIR}/h14x1; ./run_ndncatchunks_fixed.sh /arl ${OUTPUT_FILE} ${RESULTS_FILE_ARL} 20"
		echo "sleep 60"	
		sleep 60

		
		echo "running again - 50mb"
		RESULTS_FILE_ONL=${PWD}/RESULTS/ONL_50mb_${i}_2
		RESULTS_FILE_ARL=${PWD}/RESULTS/ARL_50mb_${i}_2
		OUTPUT_FILE=${PWD}/o_50mb_${i}_2		

		echo "ssh for onl "
		ssh -x $h14x1 "cd ${NDN_DIR}/h14x1; ./run_ndncatchunks_fixed.sh /onl ${OUTPUT_FILE} ${RESULTS_FILE_ONL} 20"
		echo "sleep 60"	
		sleep 60
		
		echo "ssh for arl "
		ssh -x $h14x1 "cd ${NDN_DIR}/h14x1; ./run_ndncatchunks_fixed.sh /arl ${OUTPUT_FILE} ${RESULTS_FILE_ARL} 20"
		echo "sleep 60"	
		sleep 60	
		
		
		cleanup

	
###########################
		sleep 10
        i=$((i+1))
    
    done


#!/bin/bash


#RESULTS_FILE_MIN_0_5_STATS=./RESULTS/min.0.5_stats.results.2024.Jan.30.20.43
#RESULTS_FILE_MIN_0_5_STATS=./RESULTS/min.0.5_stats.results.2024.Jan.31.13.15
RESULTS_FILE_MIN_0_5_STATS=./RESULTS/min.0.5_stats.results.2024.Jan.31.16.09
RESULTS_FILE_1MB_0_5_STATS=./RESULTS/1mb.0.5_stats.results.2024.Jan.30.20.43
RESULTS_FILE_25MB_0_5_STATS=./RESULTS/25mb.0.5_stats.results.2024.Jan.30.20.43
RESULTS_FILE_50MB_0_5_STATS=./RESULTS/50mb.0.5_stats.results.2024.Jan.30.20.43

#RESULTS_FILE_MIN_1_0_STATS=./RESULTS/min.1.0_stats.results.2024.Jan.30.23.19
#RESULTS_FILE_MIN_1_0_STATS=./RESULTS/min.1.0_stats.results.2024.Jan.31.13.45
RESULTS_FILE_MIN_1_0_STATS=./RESULTS/min.1.0_stats.results.2024.Jan.31.16.38
RESULTS_FILE_1MB_1_0_STATS=./RESULTS/1mb.1.0_stats.results.2024.Jan.30.23.19
RESULTS_FILE_25MB_1_0_STATS=./RESULTS/25mb.1.0_stats.results.2024.Jan.30.23.19
RESULTS_FILE_50MB_1_0_STATS=./RESULTS/50mb.1.0_stats.results.2024.Jan.30.23.19

#RESULTS_FILE_MIN_NO_STATS=./RESULTS/min.no_stats.results.2024.Jan.31.01.40
#RESULTS_FILE_MIN_NO_STATS=./RESULTS/min.no_stats.results.2024.Jan.31.14.14
RESULTS_FILE_MIN_NO_STATS=./RESULTS/min.no_stats.results.2024.Jan.31.17.07
RESULTS_FILE_1MB_NO_STATS=./RESULTS/1mb.no_stats.results.2024.Jan.31.01.40
RESULTS_FILE_25MB_NO_STATS=./RESULTS/25mb.no_stats.results.2024.Jan.31.01.40
RESULTS_FILE_50MB_NO_STATS=./RESULTS/50mb.no_stats.results.2024.Jan.31.01.40

#RESULTS_FILE_MIN_NO_ENVOY=./RESULTS/min.results.2024.Jan.31.09.24
#RESULTS_FILE_MIN_NO_ENVOY=./RESULTS/min.results.2024.Jan.31.12.47
RESULTS_FILE_MIN_NO_ENVOY=./RESULTS/min.results.2024.Jan.31.15.10
RESULTS_FILE_1MB_NO_ENVOY=./RESULTS/1mb.results.2024.Jan.31.09.24
RESULTS_FILE_25MB_NO_ENVOY=./RESULTS/25mb.results.2024.Jan.31.09.24
RESULTS_FILE_50MB_NO_ENVOY=./RESULTS/50mb.results.2024.Jan.31.09.24

#RESULTS_FILE_1MB_NO_ENVOY=./RESULTS/1mb.results.2024.Jan.29.09.57
#RESULTS_FILE_25MB_NO_ENVOY=./RESULTS/25mb.results.2024.Jan.29.09.57
#RESULTS_FILE_50MB_NO_ENVOY=./RESULTS/50mb.results.2024.Jan.29.09.57
#
#RESULTS_FILE_1MB_NO_STATS=./RESULTS/1mb.results.2024.Jan.27.08.38
#RESULTS_FILE_25MB_NO_STATS=./RESULTS/25mb.results.2024.Jan.27.08.38
#RESULTS_FILE_50MB_NO_STATS=./RESULTS/50mb.results.2024.Jan.27.08.38
#
#RESULTS_FILE_1MB_0_5_STATS=./RESULTS/1mb.results.2024.Jan.27.15.07
#RESULTS_FILE_25MB_0_5_STATS=./RESULTS/25mb.results.2024.Jan.27.15.07
#RESULTS_FILE_50MB_0_5_STATS=./RESULTS/50mb.results.2024.Jan.27.15.07
#
#RESULTS_FILE_1MB_1_0_STATS=./RESULTS/1mb.results.2024.Jan.27.21.26
#RESULTS_FILE_25MB_1_0_STATS=./RESULTS/25mb.results.2024.Jan.27.21.26
#RESULTS_FILE_50MB_1_0_STATS=./RESULTS/50mb.results.2024.Jan.27.21.26
#

echo "Min File, No Envoy "
# Time elapsed:
results=`grep "Time elapsed:" $RESULTS_FILE_MIN_NO_ENVOY | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Time_elapsed	$results"

# Segments received:
results=`grep "Segments received:" $RESULTS_FILE_MIN_NO_ENVOY | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Segments_received	$results"

# Transferred size:
results=`grep "Transferred size:" $RESULTS_FILE_MIN_NO_ENVOY | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Transferred_size	$results"

## Goodput:
#results=`grep "Goodput:" $RESULTS_FILE_MIN_NO_ENVOY | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
#echo "	Goodput	$results"

echo "	"

echo "Min File, No Stats Collected"
# Time elapsed:
results=`grep "Time elapsed:" $RESULTS_FILE_MIN_NO_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Time_elapsed	$results"

# Segments received:
results=`grep "Segments received:" $RESULTS_FILE_MIN_NO_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Segments_received	$results"

# Transferred size:
results=`grep "Transferred size:" $RESULTS_FILE_MIN_NO_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Transferred_size	$results"

## Goodput:
#results=`grep "Goodput:" $RESULTS_FILE_MIN_NO_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
#echo "	Goodput	$results"

echo "	"

echo "Min File, Stats Collected 1/sec"
# Time elapsed:
results=`grep "Time elapsed:" $RESULTS_FILE_MIN_1_0_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Time_elapsed	$results"

# Segments received:
results=`grep "Segments received:" $RESULTS_FILE_MIN_1_0_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Segments_received	$results"

# Transferred size:
results=`grep "Transferred size:" $RESULTS_FILE_MIN_1_0_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Transferred_size	$results"

## Goodput:
#results=`grep "Goodput:" $RESULTS_FILE_MIN_1_0_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
#echo "	Goodput	$results"

echo "	"

echo "Min File, Stats Collected 2/sec"
# Time elapsed:
results=`grep "Time elapsed:" $RESULTS_FILE_MIN_0_5_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Time_elapsed	$results"

# Segments received:
results=`grep "Segments received:" $RESULTS_FILE_MIN_0_5_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Segments_received	$results"

# Transferred size:
results=`grep "Transferred size:" $RESULTS_FILE_MIN_0_5_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Transferred_size	$results"

## Goodput:
#results=`grep "Goodput:" $RESULTS_FILE_MIN_0_5_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
#echo "	Goodput	$results"

echo "	"

echo "1mb File, No Envoy "
# Time elapsed:
results=`grep "Time elapsed:" $RESULTS_FILE_1MB_NO_ENVOY | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Time_elapsed	$results"

# Segments received:
results=`grep "Segments received:" $RESULTS_FILE_1MB_NO_ENVOY | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Segments_received	$results"

# Transferred size:
results=`grep "Transferred size:" $RESULTS_FILE_1MB_NO_ENVOY | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Transferred_size	$results"

## Goodput:
#results=`grep "Goodput:" $RESULTS_FILE_1MB_NO_ENVOY | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
#echo "	Goodput	$results"

echo "	"

echo "1mb File, No Stats Collected"
# Time elapsed:
results=`grep "Time elapsed:" $RESULTS_FILE_1MB_NO_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Time_elapsed	$results"

# Segments received:
results=`grep "Segments received:" $RESULTS_FILE_1MB_NO_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Segments_received	$results"

# Transferred size:
results=`grep "Transferred size:" $RESULTS_FILE_1MB_NO_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Transferred_size	$results"

## Goodput:
#results=`grep "Goodput:" $RESULTS_FILE_1MB_NO_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
#echo "	Goodput	$results"

echo "	"

echo "1mb File, Stats Collected 1/sec"
# Time elapsed:
results=`grep "Time elapsed:" $RESULTS_FILE_1MB_1_0_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Time_elapsed	$results"

# Segments received:
results=`grep "Segments received:" $RESULTS_FILE_1MB_1_0_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Segments_received	$results"

# Transferred size:
results=`grep "Transferred size:" $RESULTS_FILE_1MB_1_0_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Transferred_size	$results"

## Goodput:
#results=`grep "Goodput:" $RESULTS_FILE_1MB_1_0_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
#echo "	Goodput	$results"

echo "	"

echo "1mb File, Stats Collected 2/sec"
# Time elapsed:
results=`grep "Time elapsed:" $RESULTS_FILE_1MB_0_5_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Time_elapsed	$results"

# Segments received:
results=`grep "Segments received:" $RESULTS_FILE_1MB_0_5_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Segments_received	$results"

# Transferred size:
results=`grep "Transferred size:" $RESULTS_FILE_1MB_0_5_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Transferred_size	$results"

## Goodput:
#results=`grep "Goodput:" $RESULTS_FILE_1MB_0_5_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
#echo "	Goodput	$results"

echo "	"

echo "25mb File, No Envoy "
# Time elapsed:
results=`grep "Time elapsed:" $RESULTS_FILE_25MB_NO_ENVOY | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Time_elapsed	$results"

# Segments received:
results=`grep "Segments received:" $RESULTS_FILE_25MB_NO_ENVOY | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Segments_received	$results"

# Transferred size:
results=`grep "Transferred size:" $RESULTS_FILE_25MB_NO_ENVOY | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Transferred_size	$results"

## Goodput:
#results=`grep "Goodput:" $RESULTS_FILE_25MB_NO_ENVOY | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
#echo "	Goodput	$results"

echo "	"

echo "25mb File, No Stats Collected"
# Time elapsed:
results=`grep "Time elapsed:" $RESULTS_FILE_25MB_NO_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Time_elapsed	$results"

# Segments received:
results=`grep "Segments received:" $RESULTS_FILE_25MB_NO_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Segments_received	$results"

# Transferred size:
results=`grep "Transferred size:" $RESULTS_FILE_25MB_NO_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Transferred_size	$results"

## Goodput:
#results=`grep "Goodput:" $RESULTS_FILE_25MB_NO_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
#echo "	Goodput	$results"

echo "	"

echo "25mb File, Stats Collected 1/sec"
# Time elapsed:
results=`grep "Time elapsed:" $RESULTS_FILE_25MB_1_0_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Time_elapsed	$results"

# Segments received:
results=`grep "Segments received:" $RESULTS_FILE_25MB_1_0_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Segments_received	$results"

# Transferred size:
results=`grep "Transferred size:" $RESULTS_FILE_25MB_1_0_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Transferred_size	$results"

## Goodput:
#results=`grep "Goodput:" $RESULTS_FILE_25MB_1_0_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
#echo "	Goodput	$results"

echo "	"

echo "25mb File, Stats Collected 2/sec"
# Time elapsed:
results=`grep "Time elapsed:" $RESULTS_FILE_25MB_0_5_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Time_elapsed	$results"

# Segments received:
results=`grep "Segments received:" $RESULTS_FILE_25MB_0_5_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Segments_received	$results"

# Transferred size:
results=`grep "Transferred size:" $RESULTS_FILE_25MB_0_5_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Transferred_size	$results"

## Goodput:
#results=`grep "Goodput:" $RESULTS_FILE_25MB_0_5_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
#echo "	Goodput	$results"

echo "	"

echo "50mb File, No Envoy "
# Time elapsed:
results=`grep "Time elapsed:" $RESULTS_FILE_50MB_NO_ENVOY | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Time_elapsed	$results"

# Segments received:
results=`grep "Segments received:" $RESULTS_FILE_50MB_NO_ENVOY | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Segments_received	$results"

# Transferred size:
results=`grep "Transferred size:" $RESULTS_FILE_50MB_NO_ENVOY | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Transferred_size	$results"

## Goodput:
#results=`grep "Goodput:" $RESULTS_FILE_50MB_NO_ENVOY | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
#echo "	Goodput	$results"

echo "	"

echo "50mb File, No Stats Collected"
# Time elapsed:
results=`grep "Time elapsed:" $RESULTS_FILE_50MB_NO_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Time_elapsed	$results"

# Segments received:
results=`grep "Segments received:" $RESULTS_FILE_50MB_NO_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Segments_received	$results"

# Transferred size:
results=`grep "Transferred size:" $RESULTS_FILE_50MB_NO_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Transferred_size	$results"

## Goodput:
#results=`grep "Goodput:" $RESULTS_FILE_50MB_NO_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
#echo "	Goodput	$results"

echo "	"

echo "50mb File, Stats Collected 1/sec"
# Time elapsed:
results=`grep "Time elapsed:" $RESULTS_FILE_50MB_1_0_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Time_elapsed	$results"

# Segments received:
results=`grep "Segments received:" $RESULTS_FILE_50MB_1_0_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Segments_received	$results"

# Transferred size:
results=`grep "Transferred size:" $RESULTS_FILE_50MB_1_0_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Transferred_size	$results"

## Goodput:
#results=`grep "Goodput:" $RESULTS_FILE_50MB_1_0_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
#echo "	Goodput	$results"

echo "	"

echo "50mb File, Stats Collected 2/sec"
# Time elapsed:
results=`grep "Time elapsed:" $RESULTS_FILE_50MB_0_5_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Time_elapsed	$results"

# Segments received:
results=`grep "Segments received:" $RESULTS_FILE_50MB_0_5_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Segments_received	$results"

# Transferred size:
results=`grep "Transferred size:" $RESULTS_FILE_50MB_0_5_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
echo "	Transferred_size	$results"

## Goodput:
#results=`grep "Goodput:" $RESULTS_FILE_50MB_0_5_STATS | cut -d ':' -f 2 | cut -d ' ' -f 2 | tr '\n' '	'`
#echo "	Goodput	$results"

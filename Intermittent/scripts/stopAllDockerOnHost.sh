#!/bin/bash

IDS=`docker ps -aq`

if [ -z "$IDS" ]
then
  echo "No docker images present to stop" >& /dev/null
else
  docker stop $IDS >& /dev/null
fi
sleep 2
IDS=`docker ps -aq`


if [ -z "$IDS" ]
then
  echo "No docker images present to rm" >& /dev/null
else
  docker rm $IDS >& /dev/null
fi

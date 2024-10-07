#!/bin/bash


if [ $# != 0 ]
then
    echo "Usage: $0 "
    echo "Example: $0 "
    exit 0
fi

ndnpingserver /onl/h13x1

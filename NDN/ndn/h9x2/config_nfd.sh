#!/bin/bash

nfdc face create udp4://192.168.9.2:12000 persistency permanent
nfdc route add /onl udp4://192.168.9.2:12000



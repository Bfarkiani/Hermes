#!/bin/bash

nfdc route add /arl udp4://192.168.4.1:6363
nfdc route add /onl udp4://192.168.9.1:6363

#nfdc face create udp4://192.168.4.2:6362 persistency permanent
#nfdc route add /arl udp4://192.168.4.2:6362



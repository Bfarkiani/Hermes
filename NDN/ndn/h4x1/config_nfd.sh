#!/bin/bash
nfdc face create udp4://192.168.4.1:12000 persistency permanent

nfdc route add /arl udp4://192.168.4.1:12000

#nfdc face create udp4://192.168.4.2:6362 persistency permanent
#nfdc route add /arl udp4://192.168.4.2:6362



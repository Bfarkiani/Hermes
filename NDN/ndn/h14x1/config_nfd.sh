#!/bin/bash

nfdc face create udp4://192.168.13.1:12000 persistency permanent
nfdc route add /onl udp4://192.168.13.1:12000

nfdc face create udp4://192.168.13.1:13000 persistency permanent
nfdc route add /arl udp4://192.168.13.1:13000



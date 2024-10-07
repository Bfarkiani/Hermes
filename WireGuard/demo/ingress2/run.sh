#!/bin/sh
docker pull envoyproxy/envoy:dev-fbac4c7615dcfdf89ab1f846e68a881986c0968d
docker run --rm --cap-add=NET_ADMIN --cap-add=CAP_NET_ADMIN --cap-add=NET_BIND_SERVICE --cap-add=NET_RAW --add-host=host.docker.internal:host-gateway -p 10000:10000 -p 10000:10000/udp -p 10002:10002 -p 10002:10002/udp -p 10003:10003 -p 10003:10003/udp -p 9001:9001 -v "$PWD":/etc/envoy/ -v $(pwd):/var/log/envoy --name envoyhttp -t envoyproxy/envoy:dev-fbac4c7615dcfdf89ab1f846e68a881986c0968d envoy --config-path /etc/envoy/envoy.yaml --drain-time-s 5 --parent-shutdown-time-s 10 --drain-strategy "immediate" 

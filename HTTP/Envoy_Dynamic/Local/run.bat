echo on
docker pull envoyproxy/envoy-dev:448cbd60ee4e1af1f869f9f519095680b233f1e2
docker run --rm -p 12000:12000 -p 9001:9001 -v "%CD%":/etc/envoy/ --name Local --network host -t envoyproxy/envoy-dev:448cbd60ee4e1af1f869f9f519095680b233f1e2
timeout /t 30
pause
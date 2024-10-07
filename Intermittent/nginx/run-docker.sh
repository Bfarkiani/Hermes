#!/bin/sh
docker pull patrikjuvonen/docker-nginx-http3:2.1.4
#docker pull nginx:latest
docker run --rm \
  -p 0.0.0.0:8880:80 \
  -p 0.0.0.0:8443:443 \
  -v "$PWD/../testFiles/":/usr/share/nginx/html/ \
  -v "$PWD/index.html":/usr/share/nginx/html/index.html \
  -v "$PWD/nginx_conf/default.conf.onl":/etc/nginx/conf.d/default.conf \
  -v "$PWD/nginx_conf/nginx.conf.onl":/etc/nginx/nginx.conf \
  -v "$PWD/selfsign-cert/certificate.crt":/etc/nginx/conf.d/certificate.crt \
  -v "$PWD/selfsign-cert/private.key":/etc/nginx/conf.d/private.key \
 --name nginx \
  -t nginx

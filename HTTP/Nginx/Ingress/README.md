# For issuing SSL 

https://mindsers.blog/post/https-using-nginx-certbot-docker/
All certificates are stored in certbot folder and they will be renewed every 3 months. 

# HTTP 1/1.
```bash

curl http://65.0.204.88
```

You should see a page with HTTP/1.1 content

# HTTP 2
This is browser default protocol. So if you open it, you will see this one saying you are connected to HTTP/2
Also:
```bash

curl https://65.0.204.88.sslip.io/
```

# HTTP 3
First download quiche:
https://github.com/cloudflare/quiche
then run 
```bash
cargo run --bin quiche-client -- https://65.0.204.88.sslip.io/ --no-verify --http-version HTTP/3
```


# To run:
We have a running instance at https://65.0.204.88.sslip.io/
But if you want to run on your local machine, you need to run 
```bash
sudo docker compose -f docker-compose-local.yaml up 

```
or 
```bash
sudo docker compose -f docker-compose-local.yaml up -d
```

Then you just need to add hostname to your machine hosts to have a valid certificate.
In windows, you need to modify 
```
C:\Windows\System32\drivers\etc\hosts 
```
and add 
```
<IP of your local deployment> 65.0.204.88.sslip.io 
```
For Linux you need to modify 
```
/etc/hosts
```

 
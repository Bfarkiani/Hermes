#!/bin/bash
docker stop mysql
sleep 10
docker run --rm -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123 --name mysql -v "$PWD/my.cnf":/etc/mysql/conf.d/my.cnf -t -d mysql:8 

#mysql -u root -p'123' -h 127.0.0.1 -P 3306
echo "it is slow. we will wait for 2 minutes before writing into DB"
sleep 120
mysql -u "root" -p"123" -h "127.0.0.1" -P "3306" -e "create database test; use test; CREATE TABLE data25 (id int(50) NOT NULL AUTO_INCREMENT, name varchar(255) NOT NULL, data LONGBLOB, PRIMARY KEY (id) ) ENGINE=MyISAM DEFAULT CHARSET=utf8;"
mysql -u "root" -p"123" -h "127.0.0.1" -P "3306" -e "use test; CREATE TABLE data1 (id int(50) NOT NULL AUTO_INCREMENT, name varchar(255) NOT NULL, data LONGBLOB, PRIMARY KEY (id) ) ENGINE=MyISAM DEFAULT CHARSET=utf8;"
mysql -u "root" -p"123" -h "127.0.0.1" -P "3306" -e "use test; CREATE TABLE data50 (id int(50) NOT NULL AUTO_INCREMENT, name varchar(255) NOT NULL, data LONGBLOB, PRIMARY KEY (id) ) ENGINE=MyISAM DEFAULT CHARSET=utf8;"
mysql -u "root" -p"123" -h "127.0.0.1" -P "3306" -e "use test; CREATE TABLE data0 (id int(50) NOT NULL AUTO_INCREMENT, name varchar(255) NOT NULL, data LONGBLOB, PRIMARY KEY (id) ) ENGINE=MyISAM DEFAULT CHARSET=utf8;"

mysql -u "root" -p"123" -h "127.0.0.1" -P "3306" -e "SET @@GLOBAL.wait_timeout=100000; SET session wait_timeout=100000; SET @@GLOBAL.net_read_timeout=100000; SET session net_read_timeout=100000; SET @@GLOBAL.net_write_timeout=100000; SET session net_write_timeout=100000;"

echo "installing mysql python connector"
#apt-get -y install python3-pip
pip3 install mysql-connector-python
echo "inserting 25mb, 1mb, and 100mb files into DB ..."
python3 setup.py 2>&1
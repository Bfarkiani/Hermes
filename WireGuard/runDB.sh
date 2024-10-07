dbname="users"
username="ONL"
password="123456"
configDir="$PWD/configs"
port=5984
echo "listening on port $port"
rm -rf "$PWD/db/*"
docker pull couchdb:3.3.3
docker run --rm -d -p 0.0.0.0:$port:5984 -e "COUCHDB_USER=$username" -e "COUCHDB_PASSWORD=$password" --name db -t couchdb:3.3.3 
#!/bin/bash
dbname="users"
username="ONL"
password="123456"
configDir=$1
port=5984
echo "listening on port $port"
cd $PWD/../couchdb
rm -rf "$PWD/db/*"
docker pull couchdb:3.3.3
docker run --rm -d -p 0.0.0.0:$port:5984 -e "COUCHDB_USER=$username" -e "COUCHDB_PASSWORD=$password" --name db -t couchdb 
if curl -s -X GET "http://$username:$password@localhost:5984/_all_dbs" | grep -q "\"$dbname\""; then
  echo "Database $dbname exists, deleting it"
  curl -X DELETE "http://$username:$password@localhost:5984/$dbname"
fi
echo "Building $dbname DB"
sleep 5
echo "curl -X PUT http://$username:$password@localhost:5984/$dbname"

curl -X PUT "http://$username:$password@localhost:5984/$dbname"
echo "converting all Envoy configs to json files"
pushd $configDir > /dev/null
rm -f *.json
for file in $(find . -type f -name "*.yaml"); do
	name=$(basename "$file")
    echo "Processing $name"
    python3 -c 'import sys, yaml, json; json.dump(yaml.safe_load(sys.stdin), sys.stdout, indent=4)' < "$file" > "${file%.yaml}.json"
done
popd > /dev/null

echo "Adding configs to DB"
pushd $configDir > /dev/null
for file in $(find . -type f -name "*.json"); do
	name=$(basename "$file")
    echo "Processing $name"
	id="${file%.json}"
    curl -X PUT -H "Content-Type: application/json" -d @"$file" "http://$username:$password@localhost:5984/$dbname/$id"
done
popd > /dev/null

echo "adding secrets..."
curl -X PUT -d '{"envoy_rtr1":"rtr1_pass","envoy_rtr2":"rtr2_pass", "envoy_rtr3":"rtr3_pass"}' "http://$username:$password@localhost:5984/$dbname/secrets"

#read -p "Press any key to continue... " -n1 -s


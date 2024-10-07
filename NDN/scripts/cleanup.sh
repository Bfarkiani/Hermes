#!/bin/bash
./stopAllDocker.sh bfarkiani 

sleep 5

./stopNfd.sh bfarkiani

sleep 5

ps auxwww | grep bfarkiani | grep put | awk '{print $2}' | xargs kill -9
ps auxwww | grep bfarkiani | grep CoNEXT | awk '{print $2}' | xargs kill -9
echo "Done"
ps auxwww | grep bfarkiani
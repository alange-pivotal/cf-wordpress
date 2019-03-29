#!/bin/bash
echo "WP BACKUP started..."
cat access.json
echo "create access variables"
bbPORT=$(cat access.json | jq -r '.port')
bbDBNAME=$(cat access.json | jq -r '.name')
bbPWD=$(cat access.json | jq -r '.password')
bbUSER=$(cat access.json | jq -r '.username')
bbHOST=$(cat access.json | jq -r '.hostname')
bbDATE=$(date '+%Y-%m-%d-%H-%M-%S')
bbBACKUPFILE=$(echo 'wpbackups/wpDB-'$bbDATE'.dmp')


echo "dump sql into backupfile:$bbBACKUPFILE"

/usr/local/Cellar/mysql-client/5.7.23/bin/mysqldump -u $bbUSER -h 0 --password=$bbPWD --databases $bbDBNAME -P 63306 > $bbBACKUPFILE

echo "backup done...."

echo "closing connection ...."
bbPID=$(ps -e | grep "cf ssh wordpress" | sed -n 1p | grep -o -E '[0-9]+' | sed -n 1p)
kill -9 $bbPID
echo "done..."





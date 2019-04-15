#!/usr/bin/env bash

echo "WP RESTORE started..."

cat access.json

echo "create access variables"
bbPORT=$(cat access.json | jq -r '.port')
bbDBNAME=$(cat access.json | jq -r '.name')
bbPWD=$(cat access.json | jq -r '.password')
bbUSER=$(cat access.json | jq -r '.username')

echo "creating tmp file to import..."

sed 's/CREATE DATABASE/-- CREATE DATABASE/g' < $1 > wpbackups/tmp1.dmp
sed 's/USE /-- USE /g' < wpbackups/tmp1.dmp > wpbackups/tmp2.dmp

bbREPLACE=$(echo 'USE `'$bbDBNAME'`; ')
echo $bbREPLACE

sed '1s/^/'"$bbREPLACE"'/' < wpbackups/tmp2.dmp > wpbackups/tmpDB.dmp
rm wpbackups/tmp1.dmp
rm wpbackups/tmp2.dmp

echo "importing database..."
/usr/local/Cellar/mysql-client/5.7.23/bin/mysql -u $bbUSER -h 127.0.0.1 --password=$bbPWD -D $bbDBNAME -P 63306 < wpbackups/tmpDB.dmp

echo "closing connection ...."
bbPID=$(ps -e | grep "cf ssh wordpress" | sed -n 1p | grep -o -E '[0-9]+' | sed -n 1p)
kill -9 $bbPID
echo "done..."

echo "deleting tmp files..."
rm wpbackups/tmpDB.dmp


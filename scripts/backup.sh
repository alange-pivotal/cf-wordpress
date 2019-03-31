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
bbBACKUPFILE=$(echo 'wpbackups/db-'$bbDATE'.dmp')
bbNAME="wordpress-demo-app"

mkdir wpbackups

echo "dump sql into backupfile:$bbBACKUPFILE"

/usr/local/Cellar/mysql-client/5.7.23/bin/mysqldump -u $bbUSER -h 0 --password=$bbPWD --databases $bbDBNAME -P 63306 > $bbBACKUPFILE

echo "backup done...."

echo "closing connection ...."
bbPID=$(ps -e | grep "cf ssh $bbNAME" | sed -n 1p | grep -o -E '[0-9]+' | sed -n 1p)
kill -9 $bbPID
echo "done with database..."

echo "preparing file backup ..."
bbGUID=$(cf app $bbNAME --guid)
echo "GUID:"$bbGUID
cf curl /v2/info > cf_info.json
bbSSHENDPOINT=$(cat cf_info.json | jq -r .app_ssh_endpoint | sed "s/:.*//g")
echo "SSH_ENDPOINT:"$bbSSHENDPOINT


echo "preparing file backup ..."
bbGUID=$(cf app $bbNAME --guid)
echo "GUID:"$bbGUID
cf curl /v2/info > cf_info.json
bbSSHENDPOINT=$(cat cf_info.json | jq -r .app_ssh_endpoint | sed "s/:.*//g")
echo "SSH_ENDPOINT:"$bbSSHENDPOINT
bbSSHPORT=$(cat cf_info.json | jq -r .app_ssh_endpoint | sed "s/^.*://g")
echo "SSH_PORT:"$bbSSHPORT
#bbDATE=$(date '+%Y-%m-%d-%H-%M-%S')
echo "DATE:"$bbDATE
bbSSHUSER="cf:"$bbGUID"/0"
echo "SSH_USER:"$bbSSHUSER

bbFOLDER="wpbackups"
mkdir $bbFOLDER


echo "backup folder:"$bbFOLDER

bbSOURCE="/home/vcap/app/wordpress/wp-content/backup.zip"
echo "start backup... "$bbSOURCE
bbSSHPASS=$(cf ssh-code)
echo "SSH_PASSWORD:"$bbSSHPASS
( scripts/backup_files1.sh $bbSSHPASS $bbNAME $bbFOLDER $bbSSHENDPOINT $bbSSHUSER $bbSSHPORT $bbSOURCE)

bbSSHPASS=$(cf ssh-code)
echo "SSH_PASSWORD:"$bbSSHPASS
( scripts/backup_files2.sh $bbSSHPASS $bbNAME $bbFOLDER $bbSSHENDPOINT $bbSSHUSER $bbSSHPORT $bbSOURCE)

bbSSHPASS=$(cf ssh-code)
echo "SSH_PASSWORD:"$bbSSHPASS
( scripts/backup_files3.sh $bbSSHPASS $bbNAME $bbFOLDER $bbSSHENDPOINT $bbSSHUSER $bbSSHPORT $bbSOURCE)


echo ""
rm cf_info.json
echo ""
#echo "unzipping content without app name into backup folder: wpbackups/files/$bbDATE"
mv $bbFOLDER/backup.zip $bbFOLDER/backup-$bbDATE.zip
#cd wpbackups/$bbDATE
#unzip backup.zip
#mv home/vcap/app/files/$bbNAME/* .
#rm -rf home
#rm -f backup.zip
#zip -r backup.zip *
#mv backup.zip ../backup.tmp
#rm -rf *
#mv ../backup.tmp ../files-$bbDATE.zip
#rm -rf ../$bbDATE

echo "done..."






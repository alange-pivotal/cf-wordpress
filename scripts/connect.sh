#!/bin/bash
echo "WP BACKUP started..."

echo "create service-key"
cf create-service-key wpDB WP-EXTERNAL-ACCESS-KEY
cf service-key wpDB WP-EXTERNAL-ACCESS-KEY > access.tmp

sed '1d' access.tmp > access.json
rm access.tmp
echo "create access variables"
bbPORT=$(cat access.json | jq -r '.port')
bbHOST=$(cat access.json | jq -r '.hostname')

echo "create ssl tunnel to database"
cf ssh wordpress-demo-app -L 63306:$bbHOST:$bbPORT --skip-remote-execution --force-pseudo-tty



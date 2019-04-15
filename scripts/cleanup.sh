#!/bin/bash
echo cleanup...
cf delete-service-key wpDB WP-EXTERNAL-ACCESS-KEY -f
rm access.json





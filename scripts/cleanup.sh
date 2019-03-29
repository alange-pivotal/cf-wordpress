#!/bin/bash
echo "cleaning up..."
cf delete-service-key wpDB WP-EXTERNAL-ACCESS-KEY -f
rm access.json





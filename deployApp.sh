#!/usr/bin/env bash
cd cf-wp
cf create-service cleardb spark wpDB 
cf push
cd ..

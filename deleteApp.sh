#!/usr/bin/env bash
cf delete wordpress-demo-app -f
cf delete-service wpDB -f

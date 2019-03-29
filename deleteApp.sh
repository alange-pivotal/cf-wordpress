#!/usr/bin/env bash
cf delete wordpress-psp -f
cf delete-service wpDB -f

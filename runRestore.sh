#!/usr/bin/env bash
( ./scripts/connect.sh & )
sleep 10
( ./scripts/restore.sh $1)
( ./scripts/cleanup.sh )
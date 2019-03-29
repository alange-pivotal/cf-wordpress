#!/usr/bin/env bash
( ./scripts/connect.sh & )
sleep 10
( ./scripts/backup.sh )
( ./scripts/cleanup.sh )


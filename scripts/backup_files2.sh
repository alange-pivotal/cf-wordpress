#!/usr/bin/expect
  set bbpass [lindex $argv 0]
  set bbname [lindex $argv 1]
  set bbfolder [lindex $argv 2]
  set bbsshhost [lindex $argv 3]
  set bbsshuser [lindex $argv 4]
  set bbport [lindex $argv 5]
  set bbsource [lindex $argv 6]
  spawn scp -P $bbport -o "StrictHostKeyChecking=no" -o User=$bbsshuser $bbsshhost:$bbsource $bbfolder
  expect {
    password: {
      send $bbpass\r
      exp_continue
    }
  }


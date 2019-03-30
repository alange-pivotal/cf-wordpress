#!/usr/bin/env bash

#####################################################################
# MODIFY.SH
# Version 1.0
# to prepare the deployment and configure deployment parameters
# 2019-03-30 - Author: Andreas Lange (alange@pivotal.io)
#####################################################################


VERSION="Version 1.0 - 2019-03-30"
bbname=""
bbroute=""
bbdatabase=""
bbplan=""

varmaxlen=63

for ARGUMENT in "$@"
do
    if [[ $ARGUMENT = "--help" ]]; then
      echo ""
      echo " help: version - $VERSION"
      echo "  modify provides 4 options to customize the deployment settings:"
      echo "  keys:"
      echo "    [name=] name of the app in your cf environment without any spaces and special characters"
      echo "    [route=] route to the app (FQDN) in your cf environment without any spaces and special characters"
      echo "    [database=] name of the database service used by wordpress"
      echo "    [plan=] name of the plan of the given database"
      echo ""

    fi

    if [[ $ARGUMENT = "--version" ]]; then
      echo ""
      echo " modify script $VERSION"
      echo ""
    fi

    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)

    case "$KEY" in
            name)     bbname=${VALUE} ;;
            route)    bbroute=${VALUE} ;;
            database) bbdatabase=${VALUE};;
            plan)     bbplan=${VALUE};;
            *)
    esac


done

if [[ ! -z "$bbname" ]] || [[ ! -z "$bbroute" ]] || [[ ! -z "$bbdatabase" ]] || [[ ! -z "$bbplan" ]]; then
 echo "settings:"
fi

if [[ ! -z "$bbname" ]]; then
  echo "  name = $bbname"
  if [[ $bbname =~ [^A-Za-z0-9\-\_]+ ]] || [[ ${#bbname} -ge $varmaxlen ]]; then
    echo "incorrect format for name, value should only contain letters, numbers, dashes or underscore and not longer than $varmaxlen characters"
  else

    # replacing the name in the manifest
    echo "changing cf-wp/manifest.yml ..."
    sed 's/name:.*/name: '$bbname'/g' cf-wp/manifest.yml > cf-wp/manifest.tmp
    mv cf-wp/manifest.yml cf-wp/manifest.yml.bak
    mv cf-wp/manifest.tmp cf-wp/manifest.yml

    # changing the tunnel for the new app name
    echo "changing scripts/connect.sh ..."
    sed 's/cf ssh.*/cf ssh '$bbname' -L 63306:$bbHOST:$bbPORT --skip-remote-execution --force-pseudo-tty/g' scripts/connect.sh > scripts/connect.tmp
    mv scripts/connect.sh scripts/connect.bak
    mv scripts/connect.tmp scripts/connect.sh
    chmod +x scripts/connect.sh

    # changing the delepeApp.sh for the new app name
    echo "changing deleteApp.sh ..."
    sed 's/cf delete .*/cf delete '$bbname' -f/g' deleteApp.sh > deleteApp.tmp
    mv deleteApp.sh deleteApp.bak
    mv deleteApp.tmp deleteApp.sh
    chmod +x deleteApp.sh

  fi

fi

if [[ ! -z "$bbroute" ]]; then
  echo "  route = $bbroute"
  if [[ $bbroute =~ [^A-Za-z0-9\-\.]+ ]] || [[ ${#bbroute} -ge $varmaxlen ]]; then
    echo "incorrect format for route, value should only contain letters, numbers, dots or dashes and not longer than $varmaxlen characters"
  else
    # replacing the route in the manifest
    echo "changing cf-wp/manifest.yml ..."
    sed 's/route:.*/route: '$bbroute'/g' cf-wp/manifest.yml > cf-wp/manifest.tmp
    mv cf-wp/manifest.yml cf-wp/manifest.yml.bak
    mv cf-wp/manifest.tmp cf-wp/manifest.yml

  fi
fi

if [[ ! -z "$bbdatabase" ]] && [[ ! -z "$bbplan" ]]; then
  echo "  database = $bbdatabase"
  echo "  plan = $bbplan"
  if [[ $bbdatabase =~ [^A-Za-z0-9\-\_\.]+ ]] || [[ ${#bbdatabase} -ge $varmaxlen ]]; then
    echo "incorrect format for database, value should only contain letters, numbers, dashes dots or underscore and not longer than $varmaxlen characters"
  else
    echo "correct format for database"

    # in the case there is a database service there need to be a plan as well !
    if [[ -z "$bbplan" ]]; then
      echo "empty plan for database=$bbdatabase => you need to specify database and plan together to ensure your database service is set correctly!"
      exit 1
    else
      echo "checking plan settings"
      if [[ ! -z "$bbplan" ]]; then

          if [[ $bbplan =~ [^A-Za-z0-9\-\_\.]+ ]] || [[ ${#bbplan} -ge $varmaxlen ]]; then
            echo "incorrect format for plan, value should only contain letters, numbers, dots, dashes or underscore and not longer than $varmaxlen characters"
          else
            echo "correct format for plan"

            # in the case there is a database service there need to be a plan as well !
            if [[ -z "$bbdatabase" ]]; then
              echo "empty database for plan=$bbplan => you need to specify database and plan together to ensure your database service is set correctly!"
              exit 1
            else
              # replacing the database service in the deploy script
              echo "changing deployApp.sh ..."
              sed 's/cf create-service.*/cf create-service '$bbdatabase' '$bbplan' wpDB /g' deployApp.sh > deployApp.tmp
              mv deployApp.sh deployApp.bak
              mv deployApp.tmp deployApp.sh
              chmod +x deployApp.sh

             # replacing the database service in the wp-config.php file
              echo "changing cf-wp/wordpress/wp-config.php ..."
              sed 's/\$service = \$services.*/$service = $services['"'$bbdatabase'"'][0]; \/\/ pick the first MySQL service/g' cf-wp/wordpress/wp-config.php > cf-wp/wordpress/wp-config.php.tmp
              mv cf-wp/wordpress/wp-config.php cf-wp/wordpress/wp-config.php.bak
              mv cf-wp/wordpress/wp-config.php.tmp cf-wp/wordpress/wp-config.php

            fi
          fi
        fi

    fi
  fi

fi


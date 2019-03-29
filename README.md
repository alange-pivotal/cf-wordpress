# cf-wordpress

Cloudfoundry Wordpress is a repository to demostrate how to deploy wordpress 5.1.1 to cloudfoundry.
Using a MySQL database this demo uses "cleardb" plan "spark" in PWS.

Langugage Packs english and german are already included. I added "wikiwp" as an additional template.

## Installation

You need first to login to cloudfoundry with your user:

```bash
cf login -a https://api.run.pivotal io
```
 
just enter your credentials and target your ORG and SPACE

Use the ./deployApp.sh script to deploy the app and creating and binding the database service needed by wordpress.

After the script will finish:
````bash
#0   active     2019-03-29T18:21:28Z   0.0%   39.1K of 256M   8K of 512M
````

## Modify the manifest.yml (App-Name and/or App-Route)

The manifest file `cf-wp/manifest.yml` contains all information for the app deployment:

You can change the app name "-name" and the route to the app "-route: "
```
---
applications:
  - name: wordpress-demo-app
    memory: 256M
    disk_quota: 512M
    routes:
    - route: wordpress-demo-app.cfapps.io
    services:
      - wpDB
    buildpacks:
      - php_buildpack

```
as soon you change the app name you need to modify the connect script for the ssh tunnel:

```bash
scripts/connect.sh
```

```bash
cf ssh "wordpress-demo-app" -L 63306:$bbHOST:$bbPORT --skip-remote-execution --force-pseudo-tty
```

## Modify the type of MySQL Databased used

If you want to use a different database you need to change the database creation in:
`./deployApp.sh`


```bash
cf create-service cleardb spark wpDB
```

by changing `cleardb` to your database-service and `spark` to your selected plan

After changing the databse-service you need to modify the config file for wordpress: `cf-wp/wordpress/wp-config.php`

find in line #23
```php
$service = $services['cleardb'][0]; // pick the first MySQL service
```
and replace `cleardb` with your selected database-service


## Usage

In the case you are using "PWS" [Pivotal Web Services](https://run.pivotal.io) you can call the GUI by calling the URL:


[https://wordpress-demo-app.cfapps.io](https://wordpress-demo-app.cfapps.io)

## Deleting the deployment

You need first to login to cloudfoundry with your user:

```bash
cf login -a https://api.run.pivotal io
```

just enter your credentials and target your ORG and SPACE

Use the ./deleteApp.sh script to destroy the app unbinding and deleting the database service used by wordpress.

## Backing up the wordpress database

Prerequsits:
* `mysqldmp` accessible from the scripts

at this moment I havn't linked the `mysqldump` path so you change the path to `mysqldump` in: `./scripts/backup.sh`

it is set to: `/usr/local/Cellar/mysql-client/5.7.23/bin/mysqldump` 

You need first to login to cloudfoundry with your user:

```bash
cf login -a https://api.run.pivotal io
```

just enter your credentials and target your ORG and SPACE

In the next step you shoud cd to your cf-wordpress folder to execute the backup script. The backup script will create temporary service credentials for the database and then dump the database to the `./wpbackup` folder by using a cf ssh tunnel through the `demo-app`.

```bash
./runBackup.sh
```
After the backup is finished, the `cf ssh` process will be killed automatically.

## Restoring the wordpress database

Prerequsits:
* `mysql` accessible from the scripts

at this moment I havn't linked the `mysql` path so you change the path to `mysql` in: `./scripts/restore.sh`

it is set to: `/usr/local/Cellar/mysql-client/5.7.23/bin/mysql` 

You need first to login to cloudfoundry with your user:

```bash
cf login -a https://api.run.pivotal io
```

just enter your credentials and target your ORG and SPACE

In the next step you shoud cd to your cf-wordpress folder to execute the restore script. The restore script will create temporary service credentials for the database and then load the database backup from the `./wpbackup` folder to the database by using a cf ssh tunnel through the `demo-app`.

At this point you need to provide the `backup file` as the only parameter to the script
```bash
./runRestore.sh wpbackup/your-backup-file.dmp
```
After the restore is finished, the `cf ssh` process will be killed automatically.

## Additional Info

The used PHP configuration is pre configured in the `cf-wp/.bp-config` folder.

you will find the PHP Version and the webfolder in the `options.json`:

```json
{
"WEBDIR": "wordpress",
"PHP_VERSION": "{PHP_71_LATEST}"
}
```
you will find a prep script to copy needed artifacts to the wordpress folder in `cf-wp/.profile`. This script is executed on app start.

**[You would need to change the NFS path to a NFS service mount as soon you would need to integrate the file artefacts in your backup strategy!]**

```bash
#!/bin/bash

# set path of where NFS partition is mounted
MOUNT_FOLDER="/home/vcap/app/files"
echo "MOUNT_FOLDER:$MOUNT_FOLDER"

# set name of folder in which to store files on the NFS partition
WPCONTENT_FOLDER="$(echo $VCAP_APPLICATION | jq -r .application_name)"
echo "WPCONTENT_FOLDER:$WPCONTENT_FOLDER"

# Does the WPCONTENT_FOLDER exist under MOUNT_FOLDER? If not seed it.
TARGET="$MOUNT_FOLDER/$WPCONTENT_FOLDER"
echo "TARGET:$TARGET"
mkdir /home/vcap/app/files
ls -l /home/vcap/app
echo "---------------------"
ls -l /home/vcap/app/wordpress
echo "---------------------"

if [ ! -d "$TARGET" ]; then
echo "First run, moving default WordPress files to the remote volume"

SOURCE="/home/vcap/app/wordpress/wp-content-orig"
echo "SOURCE:$SOURCE"
echo "TARGET:$TARGET"

WPCON="/home/vcap/app/wordpress/wp-content"
mv "$SOURCE" "$TARGET"
ln -s "$TARGET" "/home/vcap/app/wordpress/wp-content"

echo "WPCON:$WPCON"
# Write warning to remote folder
echo "!! WARNING !! DO NOT EDIT FILES IN THIS DIRECTORY!!" > \
"$TARGET/WARNING_DO_NOT_EDIT_THIS_DIRECTORY"
else
ln -s "$TARGET" "$WPCON"
rm -rf "$SOURCE" # we don't need this
fi
echo "--------------------"
ls -l /home/vcap/app/wordpress
echo "--------------------"
ls -l /home/vcap/app/files
echo "--------------------"
ls -l /home/vcap/app/wordpress/wp-content
echo "------END-----------"

```


#
This demo was created by Andreas Lange - alange@pivotal.io



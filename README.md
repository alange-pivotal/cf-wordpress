# cf-wordpress

Cloudfoundry Wordpress is a repository to demostrate how to deploy wordpress 5.1.1 to cloudfoundry.
Using a MySQL database this demo uses "cleardb" plan "spark" in PWS.
##
Langugage Packs english and german are already included. I added "wikiwp" as an additional template. 
NEW: kanban plugin added to wordpress. The open kanban plugin can be activated in the plugins menu.



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
## Modifying deployment parameters using `modify.sh`

I have added a new script `modify.sh` which can help you to change deployment settings.

Following settings can be changed:
* name - Name of the deployed app 
* route - Route as FQDN to your app
* database - Name of the database service (MySQL) which you want to use from your marketplace
* plan - the plan you select from the database service

**database and plan** needs to be used in combination to ensure you select a valid service/plan combination!

```bash
./modify.sh --help
```
```
 help: version - Version 1.0 - 2019-03-30
  modify provides 4 options to customize the deployment settings:
  keys:
    [name=] name of the app in your cf environment without any spaces and special characters
    [route=] route to the app (FQDN) in your cf environment without any spaces and special characters
    [database=] name of the database service used by wordpress
    [plan=] name of the plan of the given database
```

**Example to modify all parameters:**
```bash
./modify.sh name=wordpress-example route=wordpressexample.cfapps.io database=p.mysql plan=small
```

All files and scripts as already described will be changed automatically.


## Optional modify the manifest.yml (App-Name and/or App-Route) - manuel steps

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

## optional modify the type of MySQL Databased used - manuel steps

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

## Backing up the wordpress database and filesystem

Prerequsits:
* `mysqldmp` accessible from the scripts
* `ssh` accessible from the scripts
* `scp` accessible from the scripts
* `#!/usr/bin/expect` accessible from the scripts

at this moment I havn't linked the `mysqldump` path so you change the path to `mysqldump` in: `./scripts/backup.sh`

it is set to: `/usr/local/Cellar/mysql-client/5.7.23/bin/mysqldump` 

You need first to login to cloudfoundry with your user:

```bash
cf login -a https://api.run.pivotal io
```

just enter your credentials and target your ORG and SPACE

In the next step you shoud cd to your cf-wordpress folder to execute the backup script. The backup script will create temporary service credentials for the database and then dump the database to the `./wpbackups` folder by using a cf ssh tunnel through the `demo-app`.
As well now the filesystem /home/vcap/app/files/APP-NAME/* is backed up as well and will appear as files-date.zip in your backup folder wpbackups.

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
y
```
## Distribution
feel free to copy and use the cf related deployment and preparation files. 
You can find the Public License of [Wordpress](https://wordpress.org/about/license/) by klicking this link. 

#
This demo was created by Andreas Lange - alange@pivotal.io



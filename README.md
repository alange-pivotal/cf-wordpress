# cf-wordpress

Cloudfoundry Wordpress is a repository to demostrate how to deploy wordpress 5.1.1 to cloudfoundry.
Using a MySQL database this template uses "clearddb" plan "spark" in PWS.

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

#
This demo was created by Andreas Lange - alange@pivotal.io



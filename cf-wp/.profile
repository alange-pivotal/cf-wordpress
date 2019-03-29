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


#!/bin/bash

#
# creates manifest file for autoupdater and copies sysupgrade images to autoupdater location
#

# create missing model identifiers on the router with the following command:
# cat /tmp/sysinfo/model | tr '[A-Z]' '[a-z]' | sed -r 's/[^a-z0-9]+/-/g;s/-$//'
#
# add identifier to model_list with proper sysupgrade.img

# Firmware version to update to
firmware_version=0.6.3

firmware_path=/var/www/firmware

webserver_root=/var/www/
rel_autoupdater_path=freifunk/firmware/autoupdater/


# **** NO CHANGES BELOW THIS LINE ******

# install sha512sum command
#apt-get --assume-yes install coreutils

# test for sha512sum command
[ ! -e "/usr/bin/sha512sum" ] && echo "Install sha512sum command (Debian package coreutils)" && exit 1
# test for model_list
[ ! -e model_list ] && echo "model_list file not present" && exit 1

# create path to autoupdater directory and set webserver owner
mkdir -p $webserver_root$rel_autoupdater_path
chown -f www-data.www-data $rel_autoupdater_path

echo -e "Generating manifest...\n"

# remove old manifest
rm -f manifest
touch manifest

# build file head
echo -e "BRANCH=stable\n\n# model version sha512sum filename" >> manifest


cat ./model_list | while read linha; do

  model=`echo $linha | cut -d' ' -f1`
  firmware=`echo $linha | cut -d' ' -f2`
  target_system=`echo $linha | cut -d' ' -f2 | cut -d'-' -f2`
  sum=`sha512sum $firmware_path/$firmware_version/$target_system/$firmware | cut -d' ' -f1`

  echo $model $firmware_version $sum $firmware >> manifest

  # cp sysupgrade.img to correct position in fs tree and set owner
  echo "copying ...$target_system/$firmware to $webserver_root$rel_autoupdater_path" 
  cp $firmware_path/$firmware_version/$target_system/$firmware $webserver_root/$rel_autoupdater_path
  chown -f www-data.www-data $webserver_root/$rel_autoupdater_path/$firmware

done

# build file tail
echo -e "\n# after three dashes follow the ecdsa signatures of everything above the dashes" >> manifest

# output further info on next steps
echo -e "\nManifest successfully created.\nPlease sign with ecdsasign and add signatures below three dashes. Place each signature in a separate line.\nCopy manifest to $webserver_root$rel_autoupdater_path.\n"
echo -e "Don't forget to assign correct autoupdater v6 address to interface bat0 on the update server: ip addr add <addr> dev bat0"
echo -e "Address can be found here: https://github.com/ffulm/firmware/blob/master/files/etc/config/autoupdater"

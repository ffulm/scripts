#!/bin/bash

# create missing model identifiers on the router with the following command:
# cat /tmp/sysinfo/model | tr '[A-Z]' '[a-z]' | sed -r 's/[^a-z0-9]+/-/g;s/-$//'
#
# add identifier to model_list with proper sysupgrade.img

# Firmware version to update to
firmware_version=0.4.5

firmware_path=/var/www/firmware
target_system=ar71xx


# **** NO CHANGES BELOW THIS LINE ******

# install sha512sum command
#apt-get --assume-yes install coreutils

# test for sha512sum command
[ ! -e "/usr/bin/sha512sum" ] && echo "Install sha512sum command (Debian package coreutils)" && exit 1
# test for model_list
[ ! -e model_list ] && echo "model_list file not present"  && exit 1

# remove old manifest
rm -f manifest
touch manifest

# build file head
echo -e "BRANCH=stable\n\n#model version sha512sum filename" >> manifest


cat ./model_list | while read linha; do

  model=`echo $linha | cut -d' ' -f1`
  firmware=`echo $linha | cut -d' ' -f2`
  sum=`sha512sum $firmware_path/$firmware_version/$target_system/$firmware | cut -d' ' -f1`

  echo $model $firmware_version $sum $firmware >> manifest

done

# build file tail
echo -e "\n# after three dashes follow the ecdsa signatures of everything above the dashes" >> manifest

echo -e "Manifest successfully created.\nPlease sign with ecdsasign and add signatures below three dashes. Place each signature in a separate line."

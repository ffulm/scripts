#!/bin/sh
file="/var/www/freifunk/firmware/autoupdater/missing_models"
if [ `stat --printf="%s" $file` -lt 1024000 ]; then
  echo "$QUERY_STRING" >> $file
fi

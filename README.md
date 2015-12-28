# Scripts
## Autoupdater
Contains script to ease release procedure via autoupdater.

Release-HOWTO on https://github.com/freifunk-bielefeld/docs/blob/master/release_howto.md

## Missing models
Dumps model identifier of routers - these should be added to model_list manually

Necessary changes on machine with firmware repo:

/etc/lighttpd/lighttpd.conf: add mod_cgi

<pre><code>
  server.modules = (
        "mod_fastcgi",
        "mod_cgi",
        "mod_access",
        "mod_alias",
        "mod_compress",
        "mod_redirect",
        "mod_rewrite"
  )
</pre></code>
add cgi-shell assignment
<pre><code>
  cgi.assign = ( ".pl" => "/opt/perl/bin/perl", ".cgi" => "/opt/perl/bin/perl", ".sh" => "/bin/sh" )
</pre></code>

<pre><code>
touch /var/www/freifunk/firmware/autoupdater/request_image.sh
chmod +x /var/www/freifunk/firmware/autoupdater/request_image.sh
chown www-data:www-data /var/www/freifunk/firmware/autoupdater/request_image.sh
</pre></code>

<pre><code>
  #!/bin/sh
  file="/var/www/freifunk/firmware/autoupdater/missing_models"
  # restrict to 1 MB
  if [ `stat --printf="%s" $file` -lt 1024000 ]; then
     echo "$QUERY_STRING" >> $file
  fi
</pre></code>

All autoupdater requests for firmwares not available in model_list are written to missing_models file.
Size of file is restricted to 1 MB.


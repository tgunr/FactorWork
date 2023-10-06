! File: downloads.factor
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2014 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: io io.encodings.utf8 io.files kernel libc namespaces
prettyprint sequences ;

IN: playnet.admin.downloads

CONSTANT: logfiles { "accesslog37"  "accesslog32"  "accesslog73"  "accesslog149"  "accesslog233" }
: process-logfile ( name -- )
    "/tmp/" swap append  utf8 file-lines
    .
    ;


: process-logfiles ( -- )
    logfiles [ process-logfile ] each ;

: do-system ( string -- )
    dup system 0= [ ": ok" ] [ ": error" ] if  append print ;

: fetch-apache-files ( -- )
    "scp 209.144.109.37:/var/log/httpd/be-access_log* /tmp/accesslog37" do-system
    "scp 209.144.109.32:/var/log/apache2/access.log /tmp/accesslog32" do-system
    "scp 209.144.109.73:/var/log/apache2/access.log /tmp/accesslog73" do-system
    "scp 209.144.109.149:/var/log/nginx/access.log.1 /tmp/accesslog149" do-system
    "scp 66.28.224.233:/var/log/nginx/access.log /tmp/accesslog233" do-system
    ;

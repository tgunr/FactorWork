! File: playnet.factor
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2013 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors io.encodings.utf8 io.files kernel math math.parser
namespaces regexp sequences splitting unix.hosts ;

IN: playnet

: playnet-only ( hosts -- hosts )
  [ names>> R/ .*\.playnet.*/ matches? ] filter ;

: access-ssh ( hosts -- hosts )
  [ access>> R/ .*s.*/ matches? ] filter 
  [ access>> R/ .*2.*/ matches? not ] filter 
  [ access>> R/ .*-.*/ matches? not ] filter
;

: root-only ( names -- root )
  " " split  [ R/ .*\.root/ matches? ] filter  
  first ; 
 
: to-lines ( hosts -- lines )
  [ names>> root-only ] map ;

CONSTANT: dshPath "~/.dsh"

: write-dsh ( -- )
  hosts playnet-only access-ssh to-lines
  dshPath "/all" append  utf8 set-file-lines ;

: dsh ( commands -- results )
  { "which dsh" } 
: playnet-port ( ip -- port )
    "." split last  string>number 60000 +  number>string ;


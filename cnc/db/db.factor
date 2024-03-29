! File: cnc.db
! Version: 0.1
! DRI: Dave Carlton
! Description: CNC database
! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors cnc db db.sqlite kernel namespaces sequences ;

IN: cnc.db

SYMBOL: cnc-db-path cnc-db-path [ "~/icloud/3CL/Data/cnc.db" ]  initialize
TUPLE: cnc-db < sqlite-db ;

: <cnc-db> ( -- <cnc-db> )
    cnc-db new
    cnc-db-path get >>path ;

: with-cncdb ( quot -- )
    '[ <cnc-db> _ with-db ] call ; inline

: do-cncdb ( statement -- result ? )
    [ sql-query ] curry with-cncdb
    dup empty? ;


! Version: 0.1
! DRI: Dave Carlton
! Description: CNC Jobs
! Copyright (C) 2022 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: cnc db db.sqlite io.files kernel unix variables ;
IN: cnc.jobs

VARIABLE: jobs-db-path "/Users/davec/Dropbox/3CL/Data/jobs.db" 

TUPLE: jobs { path initial: jobs-db-path } db handle ;

: maybe-create ( path -- path )
    dup file-exists?
    [ dup open-rw close-file ] unless
    ;

: <jobs> ( -- jobs )
    jobs new
    ;

: with-jobs-db ( quot -- )
    '[ jobs-db-path <sqlite-db> _ with-db ] call ; inline


  

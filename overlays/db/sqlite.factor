! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors classes.tuple combinators db db.private db.queries
db.sqlite db.sqlite.errors db.sqlite.ffi db.sqlite.lib db.tuples
db.tuples.private db.types destructors interpolate kernel math
math.parser namespaces nmake random sequences sequences.deep formatting ;
IN: overlays.db.sqlite

! Define a word to add a new field to a schema
! Example usage: <mydb> "mytable" "new_field" "text" add-field
:: add-field ( db table field-name field-type -- )
    db [
        "ALTER TABLE " table append
        " ADD COLUMN '" field-name append
        "' " append  field-type append
        ";" append append 
        sql-query drop
    ] with-db ;

:: drop-field ( db table field-name -- )
    db [
        "ALTER TABLE " table append
        " DROP COLUMN '" field-name append
        "' " append  
        ";" append append 
        sql-query drop
    ] with-db ;


: rename-original-table ( db table -- )
    dup "ALTER TABLE %s RENAME TO %s_old;" sprintf
    [ sql-query drop ] curry with-db
;

: create-new-table ( class table columns -- )
    define-persistent ; 

: copy-data-to-new-table ( db table  -- )
    dup "INSERT INTO %s SELECT * FROM %s_old;" sprintf
    [ sql-query drop ] curry with-db
;

: drop-original-table ( db table -- )
    "DROP TABLE %s_old;" sprintf
    [ sql-query drop ] curry with-db
;

: rename-new-table-to-original ( db table -- )
    dup "ALTER TABLE %s_old RENAME TO %s;" sprintf
    [ sql-query drop ] curry with-db
;

:: redefine-persistent ( db class table columns -- )
    db table rename-original-table 
    class table columns create-new-table
    db table copy-data-to-new-table 
    db table drop-original-table 
    db table rename-new-table-to-original ;

! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors classes.tuple combinators db db.private db.queries
db.sqlite.errors db.sqlite.ffi db.sqlite.lib db.tuples
db.tuples.private db.types destructors interpolate kernel math
math.parser namespaces nmake random sequences sequences.deep ;
IN: db.sqlite

! Define a word to add a new field to a schema
:: add-field ( db table field-name field-type -- )
    db [
        "PRAGMA foreign_keys = OFF;\n"
        "BEGIN TRANSACTION;\n" append
        "ALTER TABLE " field-name append " ADD COLUMN " field-type append " ;" append 
        "COMMIT;" append 
        "PRAGMA foreign_keys = ON;" append
        "ROLLBACK;" append
    ] with-db ;

! Example usage: "mydb.sqlite" "mytable" "new_field" "TEXT" add-field

: rename-original-table ( db table -- )
    dup "ALTER TABLE %s RENAME TO %s_old;" sprintf
    sql-statement set
    [ sql-statement get sql-query ] with-db
;

: create-new-table ( class table columns -- )
    define-persistent ; 

: copy-data-to-new-table ( db table  -- )
    dup "INSERT INTO %s SELECT * FROM %s_old;" sprintf
    sql-statement set
    [ sql-statement get sql-query ] with-db
;

: drop-original-table ( db table -- )
    "DROP TABLE %s_old;" sprintf
    sql-statement set
    [ sql-statement get sql-query ] with-db
;

: rename-new-table-to-original ( db table -- )
    dup "ALTER TABLE %s_old RENAME TO %s;" sprintf
    sql-statement set
    [ sql-statement get sql-query ] with-db
;

:: redefine-persistent ( db class table columns -- )
    db table rename-original-table 
    class table columns create-new-table
    db table copy-data-to-new-table 
    db table drop-original-table 
    db table rename-new-table-to-original ;

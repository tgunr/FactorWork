! Copyright (C) 2011 PolyMicro Systems.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors folders folders io io.directories io.files
io.files.info io.files.links io.files.private io.files.types
io.pathnames kernel locals sequences tools.continuations ;

IN: dropbox

TUPLE: dropbox ;

CONSTANT: db-library-folder " ~/Dropbox/Private/Library"
CONSTANT: user-library-folder " ~/Library"
CONSTANT: db-appsupport-name  "Application\ Support"
CONSTANT: db-preferences-name "Preferences"

:: db-is-linked-to-db? ( symlink -- ? )
    "Dropbox" symlink read-link start
    [ " to Dropbox" print f ]
    [ " but not to Dropbox" print symlink move-aside t ] if
    ;

:: db-check-symbolic? ( path -- ? )
    path link-info type>> +symbolic-link+ =
    [ ", is symbolic" write  path db-is-linked-to-db? ]
    [ " , move aside" print  path move-aside t ] if
    ;

:: db-moved-path? ( path -- ? )
    path write
    path exists?
    [ " path exists" write path db-check-symbolic? ]
    [ " no path, will link it" print t ] if
    ;

: user-library-path ( -- path )
    user-library-folder  "/" append
    ;

:: do-appsupport ( folder -- )
    folder folder-content-names
    user-library-path db-appsupport-name append
    absolute-path cd
    [ cwd "/" append prepend ] map  
    [ db-moved-path? ] filter
    [ file-name ] map
    folder full-path folder-entries
    [ folder-in-seq? ] with filter 
    [ folder-link-cwd ] each
    ;

:: do-preferences ( folder -- )
    folder folder-content-names
    user-library-path db-preferences-name append
    absolute-path cd
    [ cwd "/" append prepend ] map  
    [ db-moved-path? ] filter
    [ file-name ] map
    folder full-path folder-entries
    [ folder-in-seq? ] with filter 
    [ folder-link-cwd ] each
;

:: do-link ( folder -- )
    user-library-path absolute-path [ cd ] keep
    "/" append folder name>> append
    db-moved-path? 
    [ folder folder-link-cwd ] [ ] if
;

:: db-process-appsupport ( folder -- )
    folder name>> db-appsupport-name =
    [ folder do-appsupport ]
    [ folder name>> db-preferences-name =
      [ folder do-preferences ]
      [ folder do-link ] if
    ] if
    ;

:: db-process-folder ( folder -- )
    folder db-process-appsupport
    ;

: db-library-item ( folder-entry -- )
    dup type>> +directory+ =
    [ db-process-folder ] [ drop ] if
    ;

: db-main ( -- )
    db-library-folder exists?
    [
        db-library-folder absolute-path folder-entries
        [ db-library-item ] each
    ] [
        "The folder " db-library-folder append
        " does not exist and it must to continue." append print
        " Check configuration setting in the \"dropbox\" vocabulary" print
    ] if
    ;

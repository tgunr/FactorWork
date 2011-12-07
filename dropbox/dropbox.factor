! Copyright (C) 2011 PolyMicro Systems.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors io io.directories io.files io.files.info
io.files.links io.files.private io.files.types io.pathnames kernel
locals sequences folders ;

IN: dropbox

TUPLE: dropbox ;

CONSTANT: db-folder-path "~/Dropbox"
CONSTANT: db-appsupport-name  "Application\ Support"

: db-library-path ( -- path )
    db-folder-path "/Library" append
    ;

: db-appsupport-path ( -- path )
    db-library-path "/" append
    db-appsupport-name append
    ;
    
:: db-check-link-to-db? ( path -- ? )
    "Dropbox" path read-link start
    [ " to Dropbox" print f ]
    [ " not Dropbox" print path move-aside t ] if ;

:: db-check-symbolic? ( path -- ? )
    path link-info type>> +symbolic-link+ =
    [ ", is symbolic" write  path db-check-link-to-db? ]
    [ " path exists, move aside" print  path move-aside t ] if ;

:: move-if-exists? ( path -- ? )
    path write
    path exists?
    [ " path exists" write path db-check-symbolic? ]
    [ " no path, link it" print t ] if
    ;

:: do-appsupport ( folder -- )
    folder folder-content-names 
    "~/Library/Application\ Support" expandingTildeInPath cd
    [ cwd "/" append prepend ] map  
    [ move-if-exists? ] filter
    [ file-name ] map
    folder full-path folder-entries
    [ folder-in-seq? ] with filter 
    [ folder-link-cwd ] each
    ;

:: db-process-appsupport ( folder -- )
    folder name>> db-appsupport-name =
    [ folder do-appsupport ] [ ] if
    ;

:: db-process-folder ( folder -- )
    folder db-process-appsupport
    ;

: db-library-item ( directory-entry -- )
    dup type>> +directory+ =
    [ db-process-folder ] [ drop ] if
    ;

: db-scan ( -- )
    P" ~/Dropbox/Private/Library" expandingTildeInPath break folder-entries
    [ db-library-item ] each
    ;

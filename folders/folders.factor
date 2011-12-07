! Copyright (C) 2011 PolyMicro Systems.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors classes.tuple io io.backend io.files io.files.links
io.files.private io.pathnames kernel locals math math.parser sequences
tools.continuations ;

IN: io.directories
: components-to-path ( seq -- path )
    "/" join ;

:: bump-name ( path -- 'path )
    break
    path path-components dup
    length 1 - swap remove-nth 
    path file-name
    path file-extension dup
    [ string>number 1 + number>string swap file-stem swap ]
    [ drop "1" ] if
    "." prepend append
    suffix components-to-path
    dup exists? [ break bump-name ] [ ] if
    ;

:: move-aside ( path -- )
    path
    path bump-name
    move-file
    ;

IN: folders
TUPLE: folder < directory-entry path ;

! : new-folder ( class -- result )
!     new 0 >>name ; inline

! C: <folder> folder
: <folder> ( name type path -- folder ) folder boa ;

! ( -- derived1 )
! folder new-folder ;

: hasTilde ( path -- ? )
    path-components first 
    first 126 =
;

: replaceTilde ( path -- path )
    path-components 0 swap remove-nth
    home prefix
    components-to-path
    ;

: expandingTildeInPath ( path -- path )
    dup hasTilde
    [ replaceTilde ] [ ] if  
    ;

:: to-folder ( directory-entry path -- folder )
    directory-entry tuple-slots
    path suffix
    folder prefix >tuple
    ;

:: full-path ( folder -- path )
    folder path>> "/" append
    folder name>> append
;

:: folder-entries ( path -- seq )
    path expandingTildeInPath
    normalize-path
    (directory-entries)
    [ name>> { "." ".." ".DS_Store" } member? not ] filter
    [ path to-folder ] map!
    ;

:: folder-content-names ( folder -- seq )
    folder full-path folder-entries
    [ name>> ] map ;

:: folder-link-cwd ( folder -- )
    cwd "/" append folder name>> append
    "linking in " over append print
    folder full-path
    break swap make-link
    ;

: folder-is-name? ( str folder -- ? )
    swap name>> =  ;

: folder-in-seq? ( folder seq -- ? )
    swap [ folder-is-name? ] with find drop ;



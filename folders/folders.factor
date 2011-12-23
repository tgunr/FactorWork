! Copyright (C) 2011 PolyMicro Systems.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors classes.tuple combinators continuations io io.backend
io.files.info io.files.links io.files.private io.files.types kernel
locals math math.parser namespaces prettyprint sequences splitting
strings tools.continuations unix.users ;

IN: io.pathnames
! IN: folders

! GENERIC: trim-whitespace ( str -- 'str )
! GENERIC: space? ( n -- ? )
! GENERIC: tab? ( n -- ? )

! M: fixnum space? ( ch -- ? ) 32 = ;
: space? ( ch -- ? ) 32 = ;
! M: fixnum tab? ( ch -- ? ) 9 = ;
: tab? ( ch -- ? ) 9 = ;

! M: string trim-whitespace ( str -- str' )
: trim-whitespace ( str -- str' )
    [ [ space? ] [ tab? ] bi or ] trim-head
    [ [ space? ] [ tab? ] bi or ] trim-tail
    ;

: components-to-path ( seq -- path )
    "/" join
    ;

: special-path? ( path -- rest ? )
    {
        { [ "resource:" ?head ] [ t ] }
        { [ "vocab:" ?head ] [ t ] }
        { [ "~" ?head ] [ t ] }
        [ f ]
    } cond ;

: home-path-?isEmpty ( path -- path' )
    [ "" = ] keep swap
    [ drop "/" ] [ ] if
    ;
    
: home-path ( path -- newpath )
    home-path-?isEmpty
    [ "/" head? ] keep
    path-components swap
    [ home prefix ]                        
    [                                      
      [ first user-passwd ] keep
      over 
      [ 0 swap remove-nth swap dir>> prefix ]
      [ nip ] if
    ] if
    components-to-path
    ;

M: string absolute-path
    trim-whitespace
    "resource:" ?head [
        trim-head-separators resource-path
        absolute-path
    ] [
        "vocab:" ?head [
            trim-head-separators vocab-path
            absolute-path
        ] [ "~" ?head
            [ home-path ]
            [ current-directory get prepend-path
            ] if
        ] if
    ] if
    ;

IN: io.directories

: path-without-extension ( path -- path )
    [ [ 46 = ] find-last drop ] keep swap head ;

: bump-name ( path -- path )
    dup file-extension string>number [
        [ path-without-extension "." ] dip 1 +
        number>string 3append
    ] [ ".1" append ] if* ;

: (move-aside-error) ( error -- )
    "move-aside: Error: " over errno>>
      number>string append
      " " append over args>> first append
      " " append swap args>> second append print
;

: move-aside ( path -- )
    dup bump-name
    [ move-file ]
    [ (move-aside-error) 2drop ]
    recover
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
    "~" head?
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

IN: io.pathnames
: (to-folder-split-path) ( x -- x x )
    path-components
    [ last ] keep
    [ length ] keep
    [ 1 - ] dip
    remove-nth
    components-to-path
    ;

: (to-folder-create-folder) ( path name ? -- folder )
    [ +directory+ swap ]
    [ +regular-file+ swap ]
    if
    folder boa
    ;

GENERIC: to-folder ( path -- folder )
M: string to-folder ( path -- folder )
    [ file-info directory? ] keep
    (to-folder-split-path)
    rot
    (to-folder-create-folder)
    ;


:: full-path ( folder -- path )
    folder path>> "/" append
    folder name>> append
;

IN: io.directories
GENERIC: to-folder ( path directory-entry -- folder )
M: directory-entry to-folder 
    tuple-slots
    swap suffix
    folder prefix
    >tuple
    ;

IN: folder
: folder-entries ( path -- seq )
    [ expandingTildeInPath normalize-path (directory-entries) ] keep
    [ [ name>> { "." ".." ".DS_Store" } member? not ] filter ] dip
    swap [ to-folder ] with map!
    ;

:: folder-content-names ( folder -- seq )
    folder full-path folder-entries
    [ name>> ] map ;

: folder-link-cwd-name ( folder -- path )
    cwd "/" append
    swap name>> append
    ;
    
: folder-link-cwd ( folder -- )
    [ folder-link-cwd-name ] keep
    "linking in " over name>> append print
    full-path
    swap
    [ make-link ]
    [ (move-aside-error) 2drop ]
    recover
    ;

: folder-is-name? ( str folder -- ? )
    swap name>> =  ;

: folder-in-seq? ( folder seq -- ? )
    swap [ folder-is-name? ] with find drop ;


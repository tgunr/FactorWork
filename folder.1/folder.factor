! File: folder.factor
! Version: 0.2
! DRI: Dave Carlton <davec@polymicro.net>
! Description: Folder Summary
! This vocabulary implements folder entries in a manner similar to directory entries.
! The primary difference is a folder entry contains the complete path to the entry
! making it easier to work with and manipulate items.
!
! Copyright (C) 2011 PolyMicro Systems.
! See http://polymicrosystems.com/license for license details.


USING: accessors checksums checksums.adler-32 checksums.fnv1
classes.tuple combinators continuations file.xattr
file.xattr.lib io io.backend io.files io.files.info
io.files.links io.streams.c kernel libc locals math math.order
math.parser namespaces prettyprint prettyprint.custom regexp
sequences sorting splitting strings unix.users words ;

IN: io.pathnames

: space? ( ch -- ? ) 32 = ;
: tab? ( ch -- ? ) 9 = ;

: trim-whitespace ( str -- str' )
    [ [ space? ] [ tab? ] bi or ] trim-head
    [ [ space? ] [ tab? ] bi or ] trim-tail
    ;

: components-to-path ( seq -- path )
    "/" join
    ;

: quote-string ( string -- string' )
    "\"" dup surround ;

: as-directory ( path -- path' )
    [ last CHAR: / = ] keep
    swap
    [ ]
    [ "/" append ] if
    ;

: as-file ( path -- path' )
    [ CHAR: / = ] trim-tail
    ;

: special-path? ( path -- rest ? )
    {
        { [ "resource:" ?head ] [ t ] }
        { [ "vocab:" ?head ] [ t ] }
        { [ "~" ?head ] [ t ] }
        [ f ]
    } cond ;

: (empty-to-root) ( path -- path' )
    [ "" = ] keep "/" swap ?
    ;

: (homepath) ( path -- newpath )
    (empty-to-root)
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
            [ (homepath) ]
            [ current-directory get prepend-path
            ] if
        ] if
    ] if
    ;

IN: io.directories

: remove-extension ( path -- path )
    [ [ CHAR: . = ] find-last drop ] keep swap head ;

: bump-name ( path -- path )
    dup file-extension string>number [
        [ remove-extension "." ] dip 1 +
        number>string 3append
    ] [ ".1" append ] if*
    dup exists?
    [ bump-name ] [ ] if
    ;

: (move-aside-error) ( error -- )
    "move-aside: Error: " over errno>>
      number>string append
      " " append over args>> first append
      " " append swap args>> second append print
;

: remove-acl ( path -- )
    "chmod -N " prepend
    system drop
    ;

: move-aside ( path -- )
    dup bump-name
    [ over remove-acl move-file ]
    [ (move-aside-error) 2drop ]
    recover
    ;

: hasTilde ( path -- ? )
    "~" head?
;

IN: io.pathnames
: last-path-component ( path -- path stem )
    path-components
    [  "/" "" ]
    [
    [ last ] keep
    [ length ] keep
    [ 1 - ] dip
    remove-nth
    components-to-path
    "/" swap append
    ]
    if-empty
;

IN: io.files.types

SYMBOL: +nonexistent-file+

IN: folder

CONSTANT: BUNDLEID "net.polymicro."

CONSTANT: TEST "~/test"
CONSTANT: DOMAIN-ID "net.polymicro."
    
TUPLE: folder-entry < directory-entry path info xattrs entries fingerprint ;

: (folder-entry) ( name info path -- name type path info xattrs entries fingerprint )
        swap normalize-path
    over ! check for existence
    [
        [ dup type>> swap ] dip  swap ! adjust stack: name type path info
    ] [
        [ drop +nonexistent-file+ ] dip f
    ] if
    f f f ! xattrs, entries and fingerprint are f until needed
    ;

 : <folder-entry> ( name info path -- folder )
     (folder-entry) folder-entry boa
     ;
    
! Accessors
: nameRead ( entry -- name )   name>> ;
: pathRead ( entry -- path )   path>> ;
: pathnameRead ( entry -- path )
    [ pathRead ] keep  [ "/" append ] dip  nameRead append ; 
: typeRead ( entry -- type )   type>> ; 
    : infoRead ( entry -- info )   info>> ;
    DEFER: does-exist?
    DEFER: pathnameGet
: (xattrs@) ( entry -- xattrs )
    dup does-exist? [
        [ xattrs>> ] keep
        swap empty?
        [ pathnameGet
          swap get-xattrs
          [ >>xattrs ] keep
          nip
        ]
        [ xattrs>> ]
        if
    ]
    [ drop f ]
    if
    ;
: xattrsRead ( entry -- xattrs )   (xattrs@) ;
: entriesRead ( entry -- entries )   entries>> ;

: nameWrite ( name entry -- )   name<< ;
: typeWrite ( type entry -- )   type<< ; 
: infoWrite ( info entry -- )   info<< ; 
: xattrsWrite ( xattrs entry -- )   xattrs<< ;
: fingerprintWrite ( fingerprint entry -- )   fingerprint<< ;

: nameGet ( entry -- name entry )
    [ name>> ] keep ;
: extensionGet ( entry -- extension entry )
    [ name>> file-extension ] keep ;
: typeGet ( entry -- type entry )
    [ type>> ] keep ;
: pathGet ( entry -- path entry )
    [ path>> ] keep ;
: pathnameGet ( entry -- pathname entry )
    [ pathnameRead ] keep ;
: infoGet ( entry -- file-info entry )
    [ info>> ] keep ;
: xattrsGet ( entry -- xattrs entry )
    [ xattrsRead ] keep ;
: entriesGet ( entry -- entries entry )
    [ entries>> ] keep ;
DEFER: fingerprintRead
: fingerprintGet ( entry -- fingerprint entry )
    [ fingerprintRead ] keep ;

: fingerprint? ( entry -- ? )
    fingerprintRead >boolean ;
         
: fingerprintKey@ ( -- key )
    BUNDLEID "checksum.fnv1-32" append ;

:: fingerprint-xattrStore ( fingerprint entry -- )
    fingerprintKey@  entry fingerprintRead  <xattr>
    entry pathnameRead  
    xattrStore
    entry xattrsRead drop ; 

:: fingerprint-xattrGet ( entry -- fingerprint )
    f :> fp!
    entry xattrsRead  ! list of xattrs
    [ entry xattrsRead
      [ name>> fingerprintKey@ = ] filter :> {xattrs} 
      {xattrs} empty? not
      [ {xattrs} first  value>> fp!
        fp entry fingerprintWrite
      ] when
    ] when
    fp
!    dup HERE.
    ;

:: fingerprint-xattrSet ( entry -- entry )
    entry type>> +regular-file+ = [
        entry pathnameRead fnv1-32 checksum-file :> fp
        fp entry  [ fingerprintWrite ] [ fingerprint-xattrStore ] 2bi
    ] when
    entry
!    fp HERE.
    ;

:: fingerprintRead ( entry -- fingerprint )  ! Read fingerprint
    entry fingerprint>> :> fp!
    fp
    [ entry fingerprint-xattrGet fp!  ! look in xattrs
      fp
      [ entry fingerprint-xattrSet fingerprint>> fp! ]  ! not found, go create
      unless
    ]
    unless
    fp
 !   fp HERE.
    ;

   
: does-exist? ( entry -- ? )
    type>> +nonexistent-file+ ≠ ;

: is-directory? ( entry -- ? )
    type>> +directory+ = ;

: is-file? ( entry -- ? )
    type>> +regular-file+ = ;

: is-symbolic? ( entry -- ? )
    type>> +symbolic-link+ = ;

: is-hidden? ( entry -- ? )
    name>> first CHAR: . = ;

: name=? ( str entry -- ? )
    swap name>> =  ;

: name=~? ( regexp entry -- ? )
    name>> swap re-contains? ; 

: name-in-seq? ( string-seq entry -- ? )
    [ name=? ] with find drop ;

: has-entries? ( entry -- ? )
    entries>> length f = not ;

: wwcd ( -- path )
    "." normalize-path ;

! Default is shallow, will not look into subdirectories
SYMBOL: deep-folder

: deep ( -- )   t deep-folder set ;
: notdeep ( -- )  f deep-folder set ;

: is-dot? ( entry -- ? )
    name>> { "." ".." } member? ;

: is-dot-dir? ( entry -- entry ? )
    [ is-directory? ] keep 
    [ is-dot? ] keep  
    [ and ] dip 
    swap
    ;

IN: string

GENERIC: to-folder ( path -- folder )

M: string to-folder ( path -- folder )
    dup [ file-info ]
    [ nip drop f ]
    recover
    [ last-path-component ] dip
    <folder-entry>
;

IN: folder

: string-to-folder ( path -- folder )
    to-folder ;

IN: io.directories

GENERIC: to-folder ( path entry -- folder )

M: directory-entry to-folder 
    tuple-slots
    swap normalize-path suffix
    folder-entry prefix
    >tuple
;

IN: folder

GENERIC: pathname ( folder-entry -- path )

M: folder-entry pathname
    pathnameRead ; 

M: folder-entry equal?
    [ fingerprintRead ] bi@ = ;

M: folder-entry hashcode*
    nip fingerprintRead ;

: error>string ( error -- string )
    "ERROR: "
    over args>> first append
    " error: " append  over errno>> number>string append
    " msg: " append  over message>> append
    " word: " append  swap  word>> name>> append
;
      
: fingerprint-entries ( entries -- entries )
    [ fingerprintGet nip ] map ;

: fingerprint-sort ( entries -- entries )
    [ fingerprintRead [ fingerprintRead ] dip  <=> ] sort ;

: spotcheck-entry ( entry -- entry )
    dup
    pathname "r" fopen >>fingerprint
    B{ }
    [ over fingerprint>> fgetc
      f over ≠ swap
      over [ rot swap suffix
             [ dup fingerprint>> 100000 1 rot fseek ] 2dip swap
           ]
      [ drop ] if
    ] loop
    adler-32 checksum-bytes
    over fingerprint>> fclose
    >>fingerprint ;

FROM: io.pathnames => absolute-path ;
M: folder-entry absolute-path pathname absolute-path ;

FROM: io.directories => (directory-entries) ;
FROM: string => to-folder ;

: (folder-entries) ( folder -- entries )
    typeGet [ +nonexistent-file+ = ] dip  swap
    [ drop { } ]
    [
        [ pathname ] keep
        [ (directory-entries) ] dip
        [ [ is-dot-dir? not nip ] filter ] dip
        swap
        [ over pathname "/" append
          [ name>> ] dip swap append to-folder
        ] map
        >>entries entries>>
    ] if
    ;

! Recurse into folder and get every file stored into entries
: (folder-entries-deep) ( folder -- entries )
   (folder-entries)
    [
        dup is-directory?
        [
            is-dot-dir? not 
            [ 
                [ pathname to-folder (folder-entries-deep) ] keep 
                swap >>entries
            ] when
        ] when
    ] map
    ;

: (deep-entries) ( entries -- all-entries )
    { } swap
    [
        dup is-directory? [
            [ is-dot-dir? not ] keep
            swap
            [ entries>> (deep-entries)
              nip append
            ] 
            [ dup is-dot? 
              [ 2drop ]
              [ drop suffix ]
              if
            ] if
        ]
        [ suffix ] if
    ] each
    ;
        
FROM: io.directories => to-folder ;
FROM: io.pathnames => pathname ;

: folder-entries ( folder -- entries )
    deep-folder get
    [ (folder-entries-deep)
      (deep-entries)
    ]
    [ (folder-entries) ]
    if
    [ is-dot? not ] filter 
;

: folder-filenames ( folder -- seq )
    folder-entries [ name>> ] map! ;

: with-folder-directory ( folder quot -- )
     [ pathname ] dip  with-directory ; inline

: with-folder ( folder quot -- )
     [ folder-entries ] dip each ; inline

: with-folder-filenames ( folder quot -- )
     [ folder-filenames ] dip each ; inline

M: folder-entry pprint* pprint-object ;

IN: io.directories

: print-linking ( path1 path2 -- )
    swap "link: " prepend print
    "  to: " prepend print
;

: link-to-current-directory ( path -- )
    normalize-path
    dup file-name
    current-directory get as-directory prepend
    2dup print-linking
    dup exists?
    [ dup move-aside ] [ ] if
    [ make-link ]
    [ (move-aside-error) 2drop ]
    recover
;


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
classes.tuple combinators continuations file.xattr io io.backend
io.directories.hierarchy io.files io.files.info io.files.links
io.streams.c kernel layouts libc locals math math.order
math.parser namespaces prettyprint.custom regexp sequences
sorting splitting strings threads unix.ffi unix.users variables
words ;

IN: strings
: space? ( ch -- ? ) 32 = ;
: tab? ( ch -- ? ) 9 = ;

: trim-whitespace ( str -- str' )
    [ [ space? ] [ tab? ] bi or ] trim-head
    [ [ space? ] [ tab? ] bi or ] trim-tail
    ;

: quote-soft ( string -- string' )
    "\"" dup surround ;

: quote-hard ( string -- string' )
    "'" dup surround ;

IN: io.pathnames
: components-to-path ( seq -- path )
    "/" join
    ;

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

CONSTANT: TEST "~/Sources"
CONSTANT: DOMAIN-ID "net.polymicro."
    
TUPLE: folder-entry < directory-entry path info xattrs entries fingerprint depth ;

: (folder-entry) ( name info path -- name type path info xattrs entries fingerprint depth )
    swap normalize-path
    over ! check for existence
    [ [ dup type>> swap ] dip  swap ] ! adjust stack: name type path info
    [ [ drop +nonexistent-file+ ] dip f
    ] if
    f f f f ! xattrs, entries, fingerprint and depth are f until needed
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

: print-names ( entries -- )
    [ name>> print ] each ;

: dot-in-name ( entries -- entries )
    dup
    [ name>> "." split  first "" = ] filter
    "Multiple . in name" print
    print-names
    ;

: more-than-2 ( entries -- entries )
    dup
    "Multiple parts" print
    [ name>> "." split length 2 = not ] filter
    print-names
    ;

: underscore-in-name ( entries -- entries )
    dup 
    "Multiple underscores" print
    [ name>> "_" split length 3 = ] filter
    print-names
    ;

: find-in-name ( entry regexp -- t|f )
    [ name>> ] dip re-contains? ; 

: filter-_1 ( seq -- seq )
    [ R/ .*_1\..*/ swap first find-in-name ] filter ;

: filter-dot-names ( seq -- seq )
    [ R/ ^\..*/ swap name=~? not ] filter ;

! Default is shallow, will not look into subdirectories

: deep ( entry -- entry )   t >>depth ;
: notdeep ( entry -- entry )  f >>depth ;

: is-dot? ( entry -- ? )
    name>> { "." ".." } member? ;

: starts-with-dot? ( entry -- ? )
    R/ ^\..*/ swap name=~? ;
    
: is-dot-dir? ( entry -- ? )
    [ is-directory? ] keep  is-dot?  and ;

IN: string
GENERIC: to-folder ( path -- folder )
GENERIC: to-folder-tree ( path -- folder )

M: string to-folder ( path -- folder )
    dup [ link-info ]
    [ nip drop f ]
    recover
    [ last-path-component ] dip
    <folder-entry>
;

M: string to-folder-tree ( path -- folder )
    to-folder deep ;
    
IN: folder
: string-to-folder ( path -- folder )
    to-folder ; ! Uses string to-folder from above

: string-to-folder-tree ( path -- folder )
    to-folder-tree ; ! Uses string to-folder-deep from above

IN: io.directories
GENERIC: to-folder ( path directory-entry -- folder )
GENERIC: to-folder-tree ( path directory-entry -- folder )

M: directory-entry to-folder 
    tuple-slots
    swap normalize-path suffix
    folder-entry prefix
    >tuple
;

M: directory-entry to-folder-tree
    tuple-slots
    swap normalize-path suffix
    folder-entry prefix
    >tuple deep
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

FROM: io.directories => (directory-entries) to-folder ;

SYMBOL: †level
SYMBOL: COUNTBY
SYMBOL: ENTRY-COUNT
    
: count-by ( n -- )   COUNTBY set  0 ENTRY-COUNT set ;
: +count ( n -- )   ENTRY-COUNT get  +  ENTRY-COUNT set ;
    
: (folder-filter) ( entry -- ? )
    is-dot-dir? not ;

: not-dot-file? ( entry -- ? )
    [ is-dot-dir? not ] keep
    starts-with-dot? not
    and
    ;
    
SYMBOL: FolderFilter

: folder-filter ( entry -- ? )
    FolderFilter get dup
    [ execute( entry -- ? ) ]
    [ drop  (folder-filter) ]
    if
    ;
    
: (folder-entries) ( folder -- entries )
    typeGet [ +nonexistent-file+ = ] dip  swap
    [ drop { } ]
    [
        yield
        [ pathname ] keep
        [ 
            [ (directory-entries) ]
            [ message>>  ": " prepend  append  print  { } ]
            recover
        ] dip
        [ [ folder-filter ] filter ] dip
        swap
        [ over pathname "/" append swap to-folder ] map
        >>entries entries>>
    ] if
    ;

SYMBOL: †test-level

FROM: string => to-folder-tree ;

! Recurse into folder and get every file stored into entries
: (folder-entries-deep) ( folder -- entries )
   (folder-entries)
    [ dup is-directory?
      [ dup is-dot-dir? not 
          [ †level get †test-level get <=
            [ †level get 1 + †level set
              [ pathname to-folder-tree (folder-entries-deep) ] keep 
              swap >>entries
            ] when 
          ] when
      ] when
    ] map
    ;

: (deep-entries) ( entries -- all-entries )
    { } swap
    [
        dup is-directory? [
            [ dup is-dot-dir? not ] retain
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
        
: folder-entries ( folder -- entries )
    dup depth>> dup
    {
      { t [ drop most-positive-fixnum ] }
      { f [ drop 0 ] }
      [ drop ]
    } case
    dup †test-level set
    0 †level set
    dup [ >>depth ] dip  0 >
    ! If depth is t, then replace with big number, pass thru otherwise
    [ (folder-entries-deep)
      (deep-entries)
    ]
    [ (folder-entries) ]
    if
;

: entry-files ( entry -- seq )
    [ entries>> ] retain
    [ name>>  over pathname as-directory  prepend ] map  nip
    ;
    
: folder-filenames ( folder -- seq )
    folder-entries [ name>> ] map! ;

: with-folder-directory ( folder quot -- )
     [ pathname ] dip  with-directory ; inline

: with-folder ( folder quot -- )
     [ folder-entries ] dip each ; inline

: with-folder-filenames ( folder quot -- )
     [ folder-filenames ] dip each ; inline

: open-entry ( entry -- )
    dup type>>
    {
        { +regular-file+ [ path>> escape-string  "open " prepend  system ] }
        { +directory+ [ pathname escape-string  "open " prepend  system ] }
        { +symbolic-link+ [ path>> escape-string  "open " prepend  system ] }
        { +nonexistent-file+ [ "Not a file" print ] }
        [ drop  "Can't determine file type" HERE. ]
    } case
    drop
    ;

SYMBOL: ERRORS
 
: copy-entry  ( from to -- )
    [ [ pathname ] dip  pathname  copy-file-into ]
    [ error>string
      HERE.
      { } 2sequence 
      ERRORS get  swap suffix
      ERRORS set
    ]
    recover    
    ;
    
: copy-entries ( from to -- )
    { } ERRORS set
    2dup [ type>> +nonexistent-file+ ≠ ] bi@ or
    [ over entries>> [ [ swap copy-entry ] retain  ] each 2drop ]
    [ 2drop ]
    if
    ;

: move-entry  ( from to -- )
    [ [ pathname ] dip  pathname  move-file-into ]
    [ error>string
      HERE.
      { } 2sequence 
      ERRORS get  swap suffix
      ERRORS set
    ]
      recover    
    ;
    
: move-entries ( from to -- )
    { } ERRORS set
    2dup [ type>> +nonexistent-file+ ≠ ] bi@ or
    [ over entries>> [ [ swap move-entry ] retain  ] each 2drop ]
    [ 2drop ]
    if
    ;


: rename-entry ( from to -- )
    2drop "Unimplemented" HERE.
    ;

: delete-entry ( entry -- )
    [ dup
      [ type>> ] retain
      {
          { +regular-file+ [ pathname delete-file ] }
          { +directory+ [ pathname delete-directory ] }
          { +symbolic-link+ [ pathname delete-file ] }
          [ 2drop ]
      } case
      +nonexistent-file+ swap type<<
    ]
    [ error>string HERE.  drop ]
    recover
;

: delete-entry-tree ( entry -- )
    pathname
    [ exists? ] retain 
    [ delete-tree ]
    [ drop ]
    if
    ;
    
SYMBOL: (link-entries)
    
: symlink-entries ( entry1 entry2 -- )
    over exists?
    [ dup delete-entry
      [ pathname ] bi@
      [ symlink ] 2keep
      pick 0≠
      [ [ " to " append ] dip
        append
        "ERROR: " prepend  HERE.
        drop
      ]
      [ drop 2drop ]
      if
    ]
    [ drop  pathname " does not exist: " append  HERE. ]
    if
    ;

: hardlink-entries ( entry1 entry2 -- )
    over exists?
    [ dup delete-entry 
      [ pathname ] bi@
      make-hard-link 
    ]
    [ drop  pathname " does not exist: " append  HERE. ]
    if
    ;

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


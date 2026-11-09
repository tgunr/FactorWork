! File: duplicates.factor
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2017 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors assocs checksums checksums.sha folder io
continuations io.directories io.files.links io.pathnames kernel layouts locals
math namespaces prettyprint regexp sequences sequences.extras
serialize splitting threads words unix.ffi ;

FROM: string => to-folder ;
FROM: folder => pathname ;
IN: folder.duplicates

CONSTANT: CHECK-FOLDER "/Volumes/alpha_music"

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

: filter-_1 ( seq:{array} -- seq:{array} )
    [ R/ .*_1\..*/ swap first find-in-name ] filter ;

: filter-dot-names ( seq:{array} -- seq:{array} )
    [ R/ ^\..*/ swap name=~? not ] filter ;

SYMBOL: collection
SYMBOL: duplicates
SYMBOL: errors  errors [ { } ] initialize
: which-to-delete? ( entry entry -- entry )
    { } 2sequence dup
    [ R/ .*_1\..*/ find-in-name ] filter 
    dup length
    [ drop first ]
    [ B drop first ] if
    ;
    
: get-entries ( -- )
    CHECK-FOLDER to-folder
    folder-entries
    fingerprint-entries
    collection set
    ;

: get-collection ( -- seq )
    collection get [
        CHECK-FOLDER qualified-directory-files
        "Collecting files:" print
        [ dup file-name print
          sha1 checksum-file
          yield ] map-zip 
        collection set
    ] unless
    collection get
    [ second ] collect-by
    ;

: filter-entries ( entries -- entries )
    filter-dot-names
    ;

CONSTANT: COLLECTION-SAVE "/tmp/collection.fstore"
: save-collection ( -- )
    collection get COLLECTION-SAVE save-fstore ;
: restore-collection ( -- )
    COLLECTION-SAVE load-fstore  collection set ; 
    
: collect-files ( path -- )
    to-folder
    "Collecting files:" print
    deep folder-entries
    filter-entries 
    [ dup name>> HERE.
      fingerprintGet
      yield
    ] map>alist
    [ first ] collect-by
    collection set
    save-collection
    ;

: shasum-dups ( dups -- shasumdups )
    "Checking full sha:" print
    [ ! V{ array array }
        [ ! { entry fingerprint }
            first ! entry
            dup pathname
            dup print yield
            sha1 checksum-file ! entry fingerprint
            >>fingerprint ! entry
            [ fingerprint>> ] keep ! fingerprint entry
            [ { } ] 2dip ! { } fingerprint entry
            swap ! entry fingerprint
            [ suffix ] dip ! { entry } fingerprint }
            suffix ! { entry fingerprint }
        ] map
    ] map
    ;

: collection-dups ( -- {dups} )
    ! any element with 2 or more items is possible dup
    collection get
    [ nip
      length 2 >=
    ] assoc-filter
    values
    ;

: name. ( entry -- entry )
    [ nameRead print ] keep ;

: remove-entry ( entry -- )
    HERE.S
    pathnameRead duplicates get delete-at ;

: delete-entry ( entry -- )
    [ [ pathname delete-file ] keep
      remove-entry ]
    [ error>string print  drop ]
    recover
;

: delete-dups ( dups -- )
    HERE.S
    [ name. delete-entry ] each ;

: dups-in-same-folder ( array -- dups )
    [ length 2 >= ] filter
    [
        [ second  [ fingerprintRead ] keep ]
        map>alist
        [ first ] collect-by values
        [ length 2 >= ] filter 
    ] map B
    ;

: collect-same-folder ( dups -- seq )
    [ second [ path>> ] keep ] map>alist
    [ first ] collect-by  values
    dups-in-same-folder
    ;

: shortest-name ( seq -- index )
    [let most-positive-fixnum :> len!  f :> result!  0 :> index! 
    [ index!
          nameRead length :> thisLen
          thisLen len <
          [ thisLen len!  index result! ] when
    ] each-index
    result ] ;

: .dupFolder ( folder -- )
    "Deleting duplicates in folder: " pprint
    pathRead print ;

: collection-by-folders ( -- )
    { }  collection get values
    [ [ second suffix ] each ] each
    [ pathnameRead ] collect-by 
    duplicates set ;

: duplicates-by-fingerprint ( -- seq )
    { }  duplicates get values
    [ [ suffix ] each ] each
    [ fingerprintRead ] collect-by 
    ;

: symlink-dups ( -- )
    duplicates-by-fingerprint
    [ nip length 2 >= ] assoc-filter values 
    [
        unclip
        "Symlink to: " over pathnameRead append print
        swap
        [ over swap
          [ pathnameRead ] bi@
          dup pprint ": " pprint
          dup delete-file
          link .
        ] each
        drop
    ] each
    ;

:: (delete-dups-in-folder) ( vector -- )
    vector 
    values :> dups!
    dups [ shortest-name ] keep nth name>> :> save
    dups [ name>> save = not ] filter dups! 
    dups empty? [
        "No duplicates" print ]
    [ dups first .dupFolder
      dups delete-dups ]
    if
    ;

: delete-dups-in-folder ( vector -- )
      [ (delete-dups-in-folder) ] each ;

SYMBOL: dup-process
\ delete-dups-in-folder dup-process set

! an array of vectors, each elementis an array of duplicate fingerprints
: process-dups ( dups -- )
    HERE.S
    [ 
      [ second pathRead ] collect-by
      values  [ length 2 >= ] filter
      dup-process get execute( x -- )
    ] each 
    ;

: test-files ( -- )
    "/Users/davec/Music/Test" collect-files ;

: collection-dedup ( -- )
    collection-by-folders
    collection-dups process-dups
    symlink-dups
    ;

: do-dups ( -- )
    collection-dups process-dups ;

SYMBOL: dup-size
0 dup-size set
:: namex ( v -- )
    v values :> dups
    dups empty? [
        dups
        [ second :> e
          e name>> .
          dup-size get
          e info>> size-on-disk>> +
          dup-size set  ] each
    ] unless ;
\ namex dup-process set

: x ( -- )
    test-files collection-dedup ;


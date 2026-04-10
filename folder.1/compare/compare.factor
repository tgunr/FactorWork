! Copyright (C) 2012 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors classes combinators folder io io.directories
io.directories.hierarchy io.pathnames kernel locals namespaces regexp
sequences sets strings tools.continuations ;
IN: folder.compare

: filter-nothing ( -- regexp )  "(?!.*)" ;
: filter-hidden ( -- regexp ) "[.].*" ;
: filter-git ( -- regexp ) ".*[.]git.*" ;

FROM: namespaces => set ;
SYMBOL: folder-filter
filter-nothing folder-filter set ! default is exclude nothing

TUPLE: folder-compare src-path dst-path dir-word filter src-entries dst-entries ;
: <folder-compare> ( src dst -- folder.compare )
    folder-compare new
    [ directory-tree-files ] >>dir-word ! default is deep compare
    folder-filter get
    dup [ ] [ drop filter-nothing <regexp> ]
        if >>filter
        swap >>dst-path
        swap  >>src-path
;

! Accessors
: «src-path ( folder.compare -- path folder-compare )
    [ src-path>> ] keep ;

: »src-path ( path folder.compare -- folder-compare )
    swap >>src-path ;

: «dst-path ( folder.compare -- path folder-compare )
    [ dst-path>> ] keep ;

: »dst-path ( path folder.compare -- folder-compare )
    swap >>dst-path ;

: «src-entries ( folder.compare -- seq folder-compare )
    [ src-entries>> ] keep ;

: »src-entries ( seq folder.compare -- folder-compare )
    swap >>src-entries ;

: «dst-entries ( folder.compare -- seq folder-compare )
    [ dst-entries>> ] keep ;

: »dst-entries ( seq folder.compare -- folder-compare )
    swap >>dst-entries ;

: create-src-entries ( folder.compare -- folder.compare' )
    [ dup filter>> 
      over src-path>>
      rot dir-word>> 
      call( path -- seq )
      [ swap matches? not ] with filter ] keep
      swap >>src-entries
;

: create-dst-entries ( folder.compare -- folder.compare' )
    [ dup filter>>
      over dst-path>>
      rot dir-word>> call( path -- seq )
      [ swap matches? not ] with filter ] keep
    swap >>dst-entries
;

: set-filter ( folder.compare filter -- folder.compare' )
    dup class-of
    {
        { string [ <regexp> ] }
        { regexp [ ] }
        [ 2drop filter-nothing <regexp> ]
    } case
    >>filter 
    ;

: set-dir-word ( folder.compare t|f -- folder.compare' )
    [ [ directory-tree-files ] >>dir-word ]
    [ [ directory-files ] >>dir-word ]
    if
    ;

: swap-entries ( folder.compare -- folder.compare )
    «src-path «src-entries
    «dst-path «dst-entries
    »src-entries »src-path
    »dst-entries »dst-path ;

SYMBOL: folder-pair

: set-folder-pair-src ( src dir-word -- seq )
    [ directory-tree-files ]
    [ directory-files ]
    if
    folder-pair get  swap >>src-entries
    src-entries>>
    ;

: set-folder-pair-dst ( dst dir-word -- seq )
    [ directory-tree-files ]
    [ directory-files ]
    if
    folder-pair get swap >>dst-entries
    dst-entries>>
    ;

FROM: namespaces => set ;
:: set-folder-pair ( src dst dir-word -- src-seq dst-seq )
    src dst <folder-compare>
    folder-pair set
    src dir-word set-folder-pair-src
    dst dir-word set-folder-pair-dst
    ;

FROM: namespaces => set ;
:: src-dst-entries ( src dst dir-word -- src-entries dst-entries )
    src dst dir-word set-folder-pair
    ;

: deep ( -- t ) t ;
: shallow ( -- f ) f ;

: create-entries ( folder.compare -- folder.compare )
    create-src-entries
    create-dst-entries ;

: new-deep-compare ( src dst -- folder.compare )
    <folder-compare> 
    deep set-dir-word
;

: new-shallow-compare ( src dst -- folder.compare )
    <folder-compare> 
    shallow set-dir-word
;

GENERIC: to-folder-compare ( src dst -- folder.compare )
M: string to-folder-compare
    <folder-compare> ;

FROM: folder => pathname ;
M: folder-entry to-folder-compare
    swap pathname
    swap pathname
    <folder-compare> ;

: src-entries ( folder.compare -- seq )
    dup
    src-entries>> dup
    [ nip ]
    [ drop create-src-entries src-entries>> ] if 
    ;

: dst-entries ( folder.compare -- seq )
    dup
    dst-entries>> dup
    [ nip ] 
    [ drop create-dst-entries dst-entries>> ] if
    ;

: folder-entries ( folder.compare -- src-entries dst-entries )
    dup src-entries    
    swap dst-entries
;

: folder-diff ( folder.compare -- seq )
    folder-entries diff ;

: folder-intersect ( folder.compare -- seq )
    folder-entries intersect
    ;

: folder-union ( folder.compare -- seq )
    folder-entries union
    ;

: folder-move ( folder.compare -- seq x )
    ! List of files in SRC not in DST
    [ folder-diff ] keep
    [ src-path>> as-directory swap [ append ] with map ] keep
    dst-path>> as-directory
    
    ! List of files in SRC and in DST
    ! List of files in DST not in SRC (prune)
    ;

FROM: string => to-folder ;
:: gather-files ( seq folder.compare -- seq1 seq2 )
    folder.compare src-path>> as-directory :> path1
    folder.compare dst-path>> as-directory :> path2
    { } { } 
    seq [ 
        [ path1 prepend to-folder
          dup is-file?  over is-hidden?  not and
          [ suffix ] [ drop ] if
        ] keep 
        path2 prepend to-folder
        dup is-file? over is-hidden?  not and
        [ rot swap suffix ] [ drop swap ] if
        swap
    ] each
    ;

FROM: folder => pathname ;
:: folder-md5diff ( folder.compare -- x )
    folder.compare folder-entries intersect
    folder.compare gather-files 
    [ [ checksum= ] 2keep
      V{ } swap prefix
      swap prefix
      swap prefix
    ] 2map
     [ first not ] filter
     [ 1 tail first ] map
    ;

: folder-rm ( folder.compare mode -- x )
    [ ] curry keep
    dst-path>> as-directory swap 
    [ over prepend ] map
    [ delete-file ] each
    drop
    ;

CONSTANT: f3 "/Volumes/mphd/Users/davec"
CONSTANT: f4 "/Users/davec"
FROM: folder => pathname ;
: compare-this ( -- x )
    f3 f4 <folder-compare>
    ;

: not-in-dst ( folder.compare -- seq )
    [ folder-diff ] keep
    src-path>> as-directory 
    swap [ append ] with map
    ;

: test-src ( -- )
    compare-this not-in-dst [ print ] each ;
 
: test-dst ( -- )
    compare-this swap-entries not-in-dst [ print ] each ;
 
: test-intersect ( -- )
    compare-this folder-intersect [ print ] each
    ;

: test-union ( -- )
    compare-this folder-union [ print ] each
    ;

: test-md5 ( -- )
    compare-this folder-md5diff [ pathname print ] each
    ;
 
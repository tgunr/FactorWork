! Copyright (C) 2012 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors checksums checksums.sha classes combinators
folder help.syntax io io.backend io.directories
io.pathnames kernel locals namespaces
regexp regexp.combinators sequences sets strings
folder tools.continuations ;

FROM: namespaces => set ;
IN: folder.compare

: filter-nothing ( -- regexp )
    "(?!.*)" <regexp> ;

: filter-hidden ( -- regexp )
    { "[/][.].*" "[.].*" }
    [ <regexp> ] map
    <or> ;

: filter-git ( -- regexp )
    ".*[.]git.*" <regexp> ;

FROM: namespaces => set ;
: folder-filter-reset ( -- )
    filter-nothing FOLDERFILTER set ! default is exclude nothing
    ;

TUPLE: folder-compare src-path dst-path dir-word filter src-entries dst-entries ;

FROM: string => >folder >folder-tree ;
: <folder-compare> ( src dst -- folder-compare )
    folder-compare new
    [ >folder-tree ] >>dir-word ! default is deep compare
    FOLDERFILTER get
    dup [ ] [ drop filter-nothing ] if >>filter
    swap >>dst-path
    swap >>src-path
;

: create-src-entries ( folder-compare -- folder-compare' )
    [ dup filter>>
      over src-path>>
      rot dir-word>> 
      call( path -- seq )
      entries>>
      [ name>> swap matches? not ] with filter ] keep
      swap >>src-entries
;

: create-dst-entries ( folder-compare -- folder-compare' )
    [ dup filter>> 
      over dst-path>>
      rot dir-word>>
      call( path -- seq )
      entries>>
      [ name>> swap matches? not ] with filter ] keep
    swap >>dst-entries
;

: set-filter ( folder-compare filter -- folder-compare' )
    dup class-of
    {
        { string [ <regexp> ] }
        { regexp [ ] }
        [ 2drop filter-nothing <regexp> ]
    } case
    >>filter 
    ;

: set-dir-word ( folder-compare t|f -- folder-compare' )
    [ [ >folder-tree ] >>dir-word ]
    [ [ >folder ] >>dir-word ]
    if
    ;

: swap-entries ( folder-compare -- folder-compare )
    [ [ src-path>> ] [ src-entries>> ] bi ] keep
    [ [ dst-path>> ] [ dst-entries>> ] bi ] keep
    swap >>src-entries  swap >>src-path
    swap >>dst-entries  swap >>dst-path ;

SYMBOL: folder-pair

: set-folder-pair-src ( src dir-word -- seq )
    [ >folder-tree ]
    [ >folder ]
    if
    folder-pair get  swap >>src-entries
    src-entries>>
    ;

: set-folder-pair-dst ( dst dir-word -- seq )
    [ >folder-tree ]
    [ >folder ]
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

: as-shallow ( folder-compare -- 'folder-compare )
    shallow set-dir-word ;

: as-deep ( folder-compare -- 'folder-compare )
    deep set-dir-word ;

: create-entries ( folder-compare -- folder-compare )
    create-src-entries
    create-dst-entries ;

: new-deep-compare ( src dst -- folder-compare )
    <folder-compare> 
    deep set-dir-word
;

: new-shallow-compare ( src dst -- folder-compare )
    <folder-compare> 
    shallow set-dir-word
;

GENERIC: to-folder-compare ( src dst -- folder-compare )
M: string to-folder-compare
    <folder-compare> ;

FROM: folder => pathname>> ;
M: folder-entry to-folder-compare
    swap pathname>>
    swap pathname>>
    <folder-compare> ;

: src-entries ( folder-compare -- seq )
    dup
    src-entries>> dup
    [ nip ]
    [ drop create-src-entries src-entries>> ] if 
    ;

: dst-entries ( folder-compare -- seq )
    dup
    dst-entries>> dup
    [ nip ] 
    [ drop create-dst-entries dst-entries>> ] if
    ;

: folder-entries ( folder-compare -- src-entries dst-entries )
    dup src-entries    
    swap dst-entries
;

: folder-diff ( folder-compare -- seq )
    folder-entries diff ;

: folder-intersect ( folder-compare -- seq )
    folder-entries intersect
    ;

: folder-union ( folder-compare -- seq )
    folder-entries union
    ;

: folder-move ( folder-compare -- seq x )
    ! List of files in SRC not in DST
    [ folder-diff ] keep
    [ src-path>> as-directory swap [ append ] with map ] keep
    dst-path>> as-directory
    
    ! List of files in SRC and in DST
    ! List of files in DST not in SRC (prune)
    ;

FROM: string => >folder ;
:: gather-files ( seq folder-compare -- seq1 seq2 )
    folder-compare src-path>> as-directory :> path1
    folder-compare dst-path>> as-directory :> path2
    { } { } 
    seq [ 
        [ path1 prepend >folder
          dup is-file?  over is-hidden?  not and
          [ suffix ] [ drop ] if
        ] keep 
        path2 prepend >folder
        dup is-file? over is-hidden?  not and
        [ rot swap suffix ] [ drop swap ] if
        swap
    ] each
    ;

: checksum= ( folder-entry folder-entery -- f )
    [ pathnameRead ] bi@
    [ [ sha-256 checksum-file ] curry ] bi@
    [ call ] bi@
    =
    ;

:: folder-fingerprint-diff ( folder-compare -- x )
    folder-compare folder-entries intersect
    folder-compare gather-files 
    [ [ checksum= ] 2keep
      V{ } swap prefix
      swap prefix
      swap prefix
    ] 2map
     [ first not ] filter ! Filter out ones not equal
     [ 1 tail first ] map 
    ;

! : folder-rm ( folder-compare mode -- x )
!     [ ] curry keep
!     dst-path>> as-directory swap 
!     [ over prepend ] map
!     [ delete-file ] each
!     drop
!     ;

: has-subpath ( path path -- path path )
    2dup
    [ normalize-path ] bi@
    [ path-components ] bi@
    [ first ] bi@
    =
    [
        [
            path-components
            path-separator "[" "]" surround
            [ join ] keep
            [ prepend ] keep
            append  ".*" append
            <regexp> { } 1sequence
            FOLDERFILTER get  prefix
            <or> FOLDERFILTER set
        ] keep
    ] when
    ;
    
FROM: folder => pathname>> ;
: compare-these ( path path -- x )
    ! check-for-subpath ! Exclude if dst subpath is in src path
    <folder-compare>
    ;

: not-in-dst ( folder-compare -- seq )
    [ folder-diff ] keep
    src-path>> as-file
    swap [ append ] with map
    ;

 

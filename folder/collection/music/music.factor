! File: music.factor
! Version: 0.1
! DRI: Dave Carlton
! Description: Music collection manipulation
! Copyright (C) 2019 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors assocs checksums checksums.sha continuations folder
folder.collection folder.collection.music io io.directories io.files.links io.pathnames
kernel layouts locals math namespaces prettyprint regexp sequences
folder.collection sequences.extras serialize splitting threads unix.ffi words folder.collection ;

IN: folder.collection.music

FROM: string => >folder ;

CONSTANT: MUSIC-FOLDER "/Users/davec/Music/Plex"
CONSTANT: MUSIC-COLLECTION "/tmp/music.fstore"

SYMBOL: SINGLES

FROM: folder.collection => (restore-collection) ;

: restore-collection ( -- )
    MUSIC-COLLECTION (restore-collection) ; 

: (singles) ( -- folder )
    SINGLES get >folder ;

: set-symbols ( collection -- )
    collection set
    MUSIC-FOLDER COLLECTION-FOLDER set
    "~/Music/Plex/Singles" SINGLES set
    \ not-dot-file? FOLDERFILTER set
    ;

: delete-single-entries ( seq -- )
    [ entry-delete-tree ] each ;

: (init-singles) ( -- )
    MUSIC-FOLDER path-collect
    collection get
    filter-single-entry
    (singles) 
    over [ over entry-move ] each drop
    delete-single-entries ;

: do-singles ( -- )
    MUSIC-COLLECTION set-symbols
    (init-singles) ;

: do-singles-new ( -- )
    f collection set
    f set-symbols
    (init-singles) ;

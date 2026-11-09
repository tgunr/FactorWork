! Copyright (C) 2012 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators folder.compare folder.tests io io.directories io.encodings.utf8
io.files io.pathnames kernel namespaces sequences tools.test ;

IN: folder.compare.tests

: create-test-file ( path filename content -- )
    [ append ] dip
    [ print ] curry
    utf8 swap
    with-file-writer ;

: create-test-files ( path -- )
    dup make-directories
    dup file-name
    {
        { "a" [ "/a-file" "aaaa" create-test-file ] }
        { "b" [ "/b-file" "bbbb" create-test-file ] }
        { "c" [ "/c-file" "cccc" create-test-file ] }
        { "d" [ "/d-file" "dddd" create-test-file ] }
        [ 2drop ]
    } case
    ;

: create-abcd-folders ( -- )
    testfolder get
    [ ]
    [ set-test-folder-path ] if
    test-folder-delete
    testfolder get [ make-directories ] keep
    { "test1" "test2" } [ over swap append ] map nip
    [ first { "/a" "/b" "/c"  } [ over swap append ] map nip ] keep
    [ second { "/c" "/d" } [ over swap append ] map nip ] keep
    drop append
    [ create-test-files ] each
    ;


CONSTANT: f1 "resource:work/folder/test/test1" 
CONSTANT: f2 "resource:work/folder/test/test2" 

: abcd-folders ( -- folder.compare )
    create-abcd-folders
    f1 f2 "\\..*" t folder.compare-new
    ;

! Try the basic first
[ t ] [ set-test-folder-path t ] unit-test
[ { "a" "a/a-file" "b" "b/b-file" } ] [ abcd-folders folder-diff ] unit-test
[ { "a" "a/a-file" "b" "b/b-file" "c" "c/c-file" "d" "d/d-file" } ] [ abcd-folders folder-union ] unit-test
[ { "c" "c/c-file" } ] [ abcd-folders folder-intersect ] unit-test


: mdtestfilter ( -- )
    f1 f2 "\\..*" t folder.compare-new
    folder-diff
    [ print ] each
    ;

CONSTANT: f3 "/Volumes/data/Users/davec/Dropbox/FactorWork"
CONSTANT: f4 "/Volumes/data/Users/davec/Dropbox/FactorWork.1"
FROM: folder => pathname ;
: mdtest ( -- )
    f3 f4 "\\..*" t folder.compare-new
    folder-diff
    ;
 

! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors cli.git folder folder.duplicates io.directories
io.launcher io.pathnames kernel namespaces scratchpad sequences
string ;

IN: cli.git
: git-add* ( path -- ) { "git" "add" } swap suffix run-process drop ;
: git-commit* ( path -- )  { "git" "commit" }  over suffix  swap "-m\"Added " prepend  suffix  run-process drop ;

: git-add ( path path -- ) [ [ git-add* ] [ git-commit* ] bi ] with-directory ;

IN: folder.tools.move-to-work

: git? ( s -- ? ) 4 head ".git" = ;
: only-gits ( f -- f )
    deep folder-entries [ name>> git? ] filter ;

:: to-dest ( src dest -- )
    src dest folder-copy-tree
    dest folder:pathname>>  as-directory  src name>> append >folder :> new
    new only-gits  [ delete-entry ] each
    new folder:pathname>> dest path>> git-add
    ;

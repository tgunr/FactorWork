! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators file-picker formatting hashtables.private
io.encodings.utf8 io.files kernel layouts math math.order math.parser
namespaces sequences splitting.extras ;
IN: cnc.tools.boundary

SYMBOLS: xmin ymin xmax ymax ;

: get-contents ( -- seq )
    most-positive-fixnum xmin set  most-positive-fixnum
    ymin set 0 xmax set  0 ymax set 
    open-file-dialog first utf8 file-lines
    [ [ "G" swap subseq? ] [ "X" swap subseq? ] [ "Y" swap subseq? ] tri  or or ] filter
    [ dup "G0" head?  swap "G1" head? or ] filter
    [ [ "G" swap subseq? ] [ "X" swap subseq? ] [ "Y" swap subseq? ] tri  or and ] filter
    ;

: isnum ( num str -- num' number )
    [ 32 = ] trim  string>number dup 0 <
    [ drop dup ] when
    ;

: process-pair ( letter number -- )
    swap {
        { "X" [
              [ xmin get swap isnum min  xmin set ]
              [ xmax get swap isnum max  xmax set ] bi
          ] }
        { "Y" [
              [ ymin get swap isnum min  ymin set ]
              [ ymax get swap isnum max  ymax set ] bi
          ] }
        [ 2drop ]
    } case ;

: process-sequence ( seq -- )
    [ process-pair ] each-pair ;

: extract ( str -- )
    "GXYZEF" split* process-sequence ;

: boundary ( -- )
    get-contents
    [ extract ] each
    xmin get ymin get ymax get xmax get  
    "Xmin: %d Ymin: %d Xmax: %d Ymax:%d\n" printf ;



! Version: 0.1
! DRI: Dave Carlton
! Description: Snapmaker 2 Machine
! Copyright (C) 2022 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: cnc cnc.machine kernel multiline ;
IN: cnc.machine.SM2

TUPLE: SM2 < machine ; 

: <SM2> ( -- SM2 )
    (( name make model type units x-max y-max z-max -- machine ))
    "SM2 CNC" "Snapmaker" "Snapmaker 2" +cnc+ +mm+ 350 360 320 SM2 new <init>
    ;


: resurface ( -- )
;    

! File: cnc.machine.1F
! Version: 0.1
! DRI: Dave Carlton
! Description: OneFinifty CNC Machines
! Copyright (C) 2022 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: cnc cnc.SM2 cnc.bit cnc.machine cnc.tools io io.launcher
 io.encodings.utf8 io.files kernel math.parser multiline sequences
libc syntax.terse ;
FROM: cnc.machine => machine ;
IN: cnc.machine.1F

TUPLE: 1F < machine ; 

: <1F> ( -- 1F )
    1F new
    (( name model type x-max y-max z-max -- machine ))
    "1F" "OneFinity J50" +cnc+ +mm+ 1220 812 133 <machine>
    ;


: >onefinity ( -- )
    "/usr/bin/scp ~/Desktop/Resurface* bbmc@onefinity.local:upload/" system 0=
    [ "ok" ] [ "fail" ] if print ;

: onefinity-clear ( -- ) 
    "ssh root@onefinity.local rm upload/*" system 0=
    [ "ok" ] [ "fail" ] if print ;


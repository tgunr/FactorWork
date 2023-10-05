! File: cnc
! Version: 0.1
! DRI: Dave Carlton
! Description: CNC Machine
! Copyright (C) 2022 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.syntax db db.sqlite kernel namespaces proquint
sequences strings uuid uuid.private extensions ;
IN: cnc

ENUM: Units +mm+ +in+ ;

! Utility
: quintid ( -- id )   uuid1 string>uuid  32 >quint ; 

: clean-whitespace ( str -- 'str )
    [  CHAR: \x09 dupd =
       over  CHAR: \x0a = or
       [ drop CHAR: \x20 ] when
    ] map string-squeeze-spaces ;









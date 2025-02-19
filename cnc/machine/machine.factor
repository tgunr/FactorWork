! Version: 0.1
! DRI: Dave Carlton
! Description: CNC Machine
! Copyright (C) 2022 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.enums alien.syntax cnc cnc.db cnc.jobs db.tuples
db.types kernel math uuid  ;

IN: cnc.machine

TUPLE: spindle id name collet rpm hp ;
spindle "SPINDLE" {
    { "id" "ID" +db-assigned-id+ }
    { "name" "NAME" TEXT }
    { "collet" "COLLET" TEXT }
    { "rpm" "RPM" INTEGER }
    { "hp" "HP" INTEGER }
} define-persistent

: <spindle> ( name collet rpm hp -- spindle )
    spindle new
    swap >>hp
    swap >>rpm
    swap >>collet
    swap >>name ;

:: find-spindle ( named -- spindle )
    [ T{ spindle { name named } } select-tuple ] with-cncdb
    dup [ drop  spindle new ] unless ; 

TUPLE: mtype id name ;

: <mtype> ( type -- machineType )  mtype new  swap >>name ;

mtype "TYPES" {
    { "id" "ID" +db-assigned-id+ }
    { "name" "NAME" TEXT }
} define-persistent

ENUM: machineIs +3d+ +cnc+ +laser+ ;
TUPLE: machine id name make model type units xmax ymax zmax  support_rotary support_tool_change id ;

machine "machine" {
    { "id" "id" TEXT }
    { "name" "name" TEXT }
    { "make" "make" TEXT }
    { "model" "model" TEXT }
    { "type" "type" INTEGER }
    { "units" "units" INTEGER }
    { "xmax" "xmax" DOUBLE }
    { "ymax" "ymax" DOUBLE }
    { "zmax" "zmax" DOUBLE }
    { "support_rotary" "support_rotary" INTEGER }
    { "support_tool_change" "support_tool_change" INTEGER }
    { "id" "id" TEXT +user-assigned-id+ +not-null+ }
} define-persistent

: <init> ( name make model type units xmax ymax zmax machine -- machine ) 
    swap >>zmax  swap >>ymax  swap >>xmax
    swap enum>number >>units  swap enum>number >>type  
    swap >>model  swap >>make  swap >>name
    quintid >>id
    ;

: <machine> ( name make model type units x-max y-max z-max -- machine ) 
    machine new <init>
    ;

:: find-machine ( named -- machine )
    [ T{ machine { name named } } select-tuple ] with-cncdb ; 


: define-spindles ( --  )
    [ spindle recreate-table
      "SM2" "ER11" 12000 0.07 <spindle> insert-tuple
      "HY"  "ER11" 24000 2.0  <spindle> insert-tuple
      "BOSCH" "ER20" 32000 1.25 <spindle> insert-tuple
    ] with-cncdb
    ;

: define-types ( -- )
    [ mtype recreate-table
      "3d" <mtype> insert-tuple
      "laser" <mtype> insert-tuple
      "cnc" <mtype> insert-tuple
    ] with-cncdb ;

: define-machines ( -- )
    [ machine recreate-table
    "SM1 3D" "Snapmaker" "2" +3d+ +mm+ 350 360 320 <machine> insert-tuple
    "SM1 Laser" "Snapmaker" "2" +laser+ +mm+ 350 360 320 <machine> insert-tuple
    "SM1 CNC" "Snapmaker" "2" +cnc+ +mm+ 350 360 320 <machine> insert-tuple
    "SM2 3D" "Snapmaker" "2" +3d+  +mm+ 350 360 320 <machine> insert-tuple
    "SM2 Laser" "Snapmaker" "2" +laser+  +mm+ 350 360 320 <machine> insert-tuple
    "SM2 CNC" "Snapmaker" "2" +cnc+  +mm+ 350 360 320 <machine> insert-tuple
    "P1"  "Prusa" "MK2.5S" +3d+ +mm+ 250 210 210 <machine> insert-tuple
    "P2"  "Prusa" "MK3S" +3d+ +mm+ 250 210 210 <machine> insert-tuple
    "1F" "Onefinity" "J50" +cnc+ +in+ 48.25 32.25 5.25 <machine> insert-tuple
    "1FL" "Onefinity" "J50" +laser+ +in+ 48.25 32.25 5.25 <machine> insert-tuple
    ] with-cncdb
    ;


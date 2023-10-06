! File: pickadisk.factor
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2016 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors assocs kernel locals math math.parser namespaces
sequences uuid ;

IN: pickadisk

TUPLE: item
    uuid parent id number kind name description ;
TUPLE: sleeve < item content ;
TUPLE: container < item sleeves ;
TUPLE: drawer < item containers ; 
TUPLE: cabinet < item
    { rows initial: { } }
    { columns initial: { } }
;

SYMBOL: itemType
SYMBOL: itemNumber

: next-item-number ( -- n )
    itemNumber get
    dup number?
    [ dup 1+ itemNumber set ] 
    [ drop 1 dup itemNumber set ]
    if
    ;

:: (set-item) ( tuple parent number kind name description -- tuple )
    tuple uuid4 >>uuid
    parent >>parent
    next-item-number >>id 
    number >>number
    kind >>kind
    name >>name
    description >>description
;

:: set-item ( tuple parent kind -- tuple )
    tuple
    parent
    itemNumber get :> i
    i
    kind
    "Number-" i number>string append dup
    kind " " append prepend
    (set-item)
    ;

:: <sleeve> ( kind content -- sleeve )
    sleeve new
    "sleeve"
    kind
    set-item
    content >>content
    ;

:: <container> ( content -- container )
    container new
    "container"
    "Box"
    set-item
    content >>sleeves
;
    
: make-test-sleeve ( -- sleeve ) 
    "DVD" { "1" "2" } <sleeve> ; 
    
: make-test-container ( -- container )
    4 iota [ drop make-test-sleeve ] map
    <container> ;

: make-test-drawer ( -- drawer )
    4 iota [ drop make-test-container ] map
    <container> ;

: init ( -- )
    1 itemNumber set
    { "CD" "DVD" "BD" } <enum> itemType set
;


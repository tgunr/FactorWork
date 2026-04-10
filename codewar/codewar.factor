! Copyright (C) 2024 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: splitting kernel math math.order math.parser sequences ;

IN: codewar

: is-valid-octet ( string -- bool )
    dup number? [ 0 swap 256 within? ] [ drop f ] if ;

: is-valid-ip? ( str -- ? ) 
    "." split
    [  [ CHAR: 1 CHAR: 9 between? not ] filter  length 0 = ] filter
    dup length 4 = [
        [ string>number ] map
        [ is-valid-octet ] filter
        t swap [ and ] each
    ]
    [ drop f ] if ;

    

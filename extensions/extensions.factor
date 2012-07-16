! Copyright (C) 2012 PolyMicro Systems.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math namespaces sequences ui.tools.listener io.directories prettyprint.custom
 ;

IN: ui
FROM: ui.private => windows ;
: (title-is=?) ( world string -- bool )
    swap title>>  = ;

: window-find-title ( string -- handle )
    windows get
    [ second over (title-is=?) ] filter
    first first swap drop ;

: listener-get ( -- handle )
    "Listener" window-find-title ;

: focus-until ( object -- object )
    dup focus>> dup
    [ swap drop focus-until ]
    [ drop ] if ;
                 
: gadget-font-size ( gadget -- size )
    focus-until font>> size>> ;

: gadget-window-size ( gadget -- size )
    dim>> ;

IN: listener
: listener-window-size ( -- size )
    get-listener gadget-window-size ;

: listener-font-size ( -- size )
    get-listener gadget-font-size ;

: listener-window-width ( -- size )
    get-listener dup
    gadget-window-size first ! width
    swap gadget-font-size / ;

IN: folder
M: folder pprint* pprint-object ;

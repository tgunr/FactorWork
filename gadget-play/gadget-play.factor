! File: gadget-play
! Version: 0.1
! DRI: Dave Carlton
! Description: Gadget playground
! Copyright (C) 2022 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes.tuple
cnc.tools.resurface.ui documents io kernel math math.parser
models models.arrow models.mapping models.product namespaces
pmlog sequences ui ui.gadgets ui.gadgets.borders
ui.gadgets.buttons ui.gadgets.editors ui.gadgets.frames
ui.gadgets.grids ui.gadgets.labels ui.gadgets.packs
ui.gadgets.scrollers ui.gadgets.sliders ui.gadgets.tracks
ui.gadgets.world ui.gadgets.worlds ui.tools.common
units.imperial units.si vocabs ;
QUALIFIED-WITH: models.range mr
IN: gadget-play

: (tuples) ( seq -- seq )
    [ tuple? ] collect-by  t swap at
    dup [
        { } swap [ tuple-slots (tuples) append ] each
    ] when
    ;

: (arrays) ( seq -- seq )
    [ array? ] collect-by
    t swap at
    ;

: tuples ( world -- seq seq )
    tuple-slots [ (tuples) ] keep
    ;

! Convert the first number to a string
: convertFirstNumberToString' ( -- quot )
  [ first number>string ] ;

: gadget-position@ ( -- {col,row} )
    gadget-position [ get 3 /mod  swap  2array ] keep  inc ;

:: add-range-gadget ( frame label range -- frame )
    frame label <label> gadget-position@ grid-add  
    range convertFirstNumberToString' <arrow> 
    <label-control> gadget-position@ grid-add 
    range horizontal <slider> gadget-position@ grid-add ;

: add-range-gadgets ( frame -- frame )
    0 gadget-position set
    "X" 0 1 0 1219 1 mr:<range> add-range-gadget
    "Y" 0 1 0 812 1 mr:<range> add-range-gadget
;

CONSTANT: start-position-options { 
    { 1 "Center" } 
    { 2 "Lower Left" }
    { 3 "Upper Left" } 
    { 4 "Lower Right" }
    { 5 "Upper Right" } 
}

: build-frame ( -- frame )
    3 8 <frame>  { 4 4 } >>gap  syntax:f >>fill?  
    add-range-gadgets
;

: gadget-panel ( cnc-gadget -- gadget )
   <pile> white-interior
   build-frame add-gadget
   { 5 5 } <border> add-gadget
    ;

TUPLE: gadget-frame < pack settings ;
: gadget-config ( -- assoc )
    H{ 
        { "X" 0 }
        { "Y" 0 }
    } ;

: <gadget-settings> ( -- control )
    gadget-config [ <model> ]  assoc-map [
    <pile>         
    "Gadgets" <label> add-gadget
    start-position get  start-position-options <radio-buttons> add-gadget
    namespace <mapping> >>model
    ] with-variables
    ;

: <gadget-gadget> ( -- gadget )
    gadget-frame new 
    vertical >>orientation
    <gadget-settings> >>settings 
    dup settings>> add-gadget
    ;

: gadget-tool ( -- )
    <gadget-gadget> { 10 10 } <border> white-interior
    <world-attributes> "gadget" >>title 
    [ { dialog-window } append ] change-window-controls 
    open-window ;

TUPLE: navigation < pack ;
TUPLE: environment < tool ;
environment { 600 300 } set-tool-dim

INITIALIZED-SYMBOL: cnc-root [ vocab new "●" >>name ]

: <navigation> ( model -- navigation )
    navigation new swap >>model vertical >>orientation 1 >>fill
    gadget-panel
    ;

: <environment> ( -- gadget )
    cnc-root get <model> 
    vertical environment new-track over >>model
    swap <navigation> <scroller> 1 track-add 
;

: environment-window ( -- )
    [ <environment> "gadget" open-window ] with-ui ; 

ALIAS: ew environment-window

: set-editor-string-no-notify ( string editor -- )
    2dup editor-string = [ 2drop ] [ set-editor-string ] if ;

WINDOW: 7g { { title "Temperature Converter" } }
    [let
    <editor> 15 >>min-cols :> C
    <editor> 15 >>min-cols :> F
    { "" "" } :> prev!
    C model>> [ doc-string ] <arrow>
    F model>> [ doc-string ] <arrow>
    2array <product>
    [
        dup prev =
        [
            dup prev [ = not ] 2map
            first 
            [
                first dec> deg-C [ deg-F ] undo >dec
                dup 1 prev set-nth
                F set-editor-string-no-notify
            ]
            [
                second dec> deg-F [ deg-C ] undo >dec
                dup 0 prev set-nth
                C set-editor-string-no-notify
            ] if
        ] unless
        f
    ] <arrow> drop
    C "Celsius =" <label> F "Fahrenheit" <label> 4array
    <shelf> swap add-gadgets
    { 10 0 } >>gap 0.5 >>align { 5 5 } <border>
    >>gadgets
    ]
;

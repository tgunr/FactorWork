! File: cnc.tools.resurface.ui
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors arrays boids.simulation calendar classes cnc.bit
 cnc.gcode cnc.tools colors fonts kernel literals
 math math.functions math.parser models models.arrow models.range
 namespaces opengl opengl.demo-support opengl.gl sequences threads
 ui ui.backend ui.commands ui.gadgets ui.gadgets.borders ui.gadgets.buttons
 ui.gadgets.frames ui.gadgets.grids ui.gadgets.labeled ui.gadgets.labels ui.gadgets.packs ui.gadgets.scrollers
 ui.gadgets.sliders ui.gadgets.status-bar ui.gadgets.tracks ui.gadgets.worlds ui.pixel-formats ui.render
 ui.tools.common vocabs multiline pmlog ;
 
IN: cnc.tools.resurface.ui

QUALIFIED-WITH: models.range mr

CONSTANT: initial-feed 1000
CONSTANT: initial-speed 15000
CONSTANT: initial-bit 25.4
CONSTANT: initial-depth 0
CONSTANT: initial-step 60
INITIALIZED-SYMBOL: gadget-position [ 0 ]

TUPLE: resurface-gadget < gadget xmax ymax bitsize spindle speed feed step ;

! Convert the first number to a string
: convertFirstNumberToString' ( -- quot )
  [ first number>string ] ;

: gadget-position@ ( -- {col,row} )
    gadget-position [ get 3 /mod  swap  2array ] keep  inc ;

:: add-range-gadget ( lFrame! theLabel theRange -- frame )
    lFrame theLabel <label> gadget-position@ grid-add  lFrame!
    lFrame theRange convertFirstNumberToString' <arrow> 
    <label-control> gadget-position@ grid-add  lFrame!
    lFrame theRange vertical <slider> gadget-position@ grid-add ;

: add-range-gadgets ( frame -- frame )
    0 gadget-position set
    "speed" initial-speed 1000 8000 30000 1000 mr:<range> add-range-gadget
    "feed" initial-feed 1000 1 12700 1000 mr:<range> add-range-gadget
    "step" initial-step 1 1 100 1 mr:<range> add-range-gadget
 B   "depth" initial-depth 1 0 100 1 mr:<range> add-range-gadget
    "bit" initial-bit 1 0 100 1 mr:<range> add-range-gadget
;

: build-frame ( -- frame )
    3 5 <frame>  { 4 4 } >>gap  syntax:f >>fill?  
    add-range-gadgets
;

: resurface-panel ( cnc-gadget -- gadget )
   <pile> white-interior
   build-frame add-gadget
   { 5 5 } <border> add-gadget
!    "Test" "red" named-color <framed-labeled-gadget> 
    ;


((    "feed" <label> { 0 1 } grid-add
    initial-feed 0 1 100 1 mr:<range>
    [ [ range-value ] <arrow>  [ number>string ] <arrow> <label-control> { 1 0 } grid-add ] 2keep
    horizontal <slider> { 2 1 } grid-add
))

TUPLE: resurface-frame < pack ;

: <resurface-gadget> ( -- gadget )
    resurface-gadget new ;

: <resurface-frame> ( -- cnc-frame )
    resurface-frame new  horizontal >>orientation
    <resurface-gadget>
 B   resurface-panel
    { 5 5 } <border> add-gadget 
    ;

TUPLE: navigation < pack ;
TUPLE: environment < tool ;

environment { 600 300 } set-tool-dim

SYMBOL: cnc-root
vocab new "●" >>name cnc-root set-global

: <navigation> ( model -- navigation )
    navigation new swap >>model vertical >>orientation 1 >>fill
    resurface-panel
    ;

:: <environment> ( -- gadget )
    cnc-root get-global <model> :> model
    vertical environment new-track model >>model
    model <navigation> <scroller> 1 track-add
    ;

: environment-window ( -- )
    [ <environment> "Resurface" open-window ] with-ui ; 

ALIAS: ew environment-window

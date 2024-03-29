! File: cnc.tools.resurface.ui
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors arrays assocs boids.simulation calendar classes
 cnc.bit cnc.gcode cnc.tools colors fonts kernel
 literals math math.functions math.parser models models.arrow
 models.mapping models.range multiline namespaces opengl opengl.demo-support
 opengl.gl pmlog sequences threads ui ui.backend
 ui.commands ui.gadgets ui.gadgets.borders ui.gadgets.buttons ui.gadgets.frames ui.gadgets.grids
 ui.gadgets.labeled ui.gadgets.labels ui.gadgets.packs ui.gadgets.scrollers ui.gadgets.sliders ui.gadgets.status-bar
 ui.gadgets.tracks ui.gadgets.worlds ui.pixel-formats ui.render ui.tools.common vocabs
  ;

IN: cnc.tools.resurface.ui

QUALIFIED-WITH: models.range mr

CONSTANT: initial-feed 1000
CONSTANT: initial_spindle_speed 15000
CONSTANT: initial_bit_diameter 25.4
CONSTANT: initial_cut_depth 0
CONSTANT: initial_stepover 60
INITIALIZED-SYMBOL: gadget-position [ 0 ]
INITIALIZED-SYMBOL: start-position [ 2 ]

TUPLE: resurface-gadget < gadget xmax ymax bitsize spindle speed feed step ;

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
    "Cut Depth" initial_cut_depth 1 0 100 1 mr:<range> add-range-gadget
    "Max Depth" initial_cut_depth 1 0 100 1 mr:<range> add-range-gadget
    "Bit Diameter" initial_bit_diameter 1 0 100 1 mr:<range> add-range-gadget
    "Spindle" initial_spindle_speed 1000 8000 30000 1000 mr:<range> add-range-gadget
    "Feed Rate" initial-feed 1000 1 12700 1000 mr:<range> add-range-gadget
    "Stepover %" initial_stepover 1 1 100 1 mr:<range> add-range-gadget
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

: resurface-panel ( cnc-gadget -- gadget )
   <pile> white-interior
   build-frame add-gadget
!    <shelf> 
!    "Start Postion" <label> add-gadget
!    start-position get  start-position-options <radio-buttons> add-gadget 
!    add-gadget
   { 5 5 } <border> add-gadget
!    "Test" "grey" named-color <framed-labeled-gadget> 
    ;

TUPLE: resurface-frame < pack settings ;
: resurface-config ( -- assoc )
    H{ 
        { "X" 0 }
        { "Y" 0 }
        { "Cut Depth" 0 }
        { "Max Depth" 0 }
        { "Bit Diameter" 0 }
        { "Spindle" 0 }
        { "Feed Rate" 0 }
        { "Stepover %" 0 }
    } ;

: <resurface-settings> ( -- control )
    resurface-config [ <model> ]  assoc-map [
    <pile>         
    "Test" <label> add-gadget
    "Starting Position" <label> add-gadget
    start-position get  start-position-options <radio-buttons> add-gadget
    namespace <mapping> >>model
    ] with-variables
    ;

: <resurface-gadget> ( -- gadget )
    resurface-frame new 
    vertical >>orientation
    <resurface-settings> >>settings 
    dup settings>> add-gadget
    ;

: resurface-tool ( -- )
    <resurface-gadget> { 10 10 } <border> white-interior
    <world-attributes> "Resurface" >>title 
    [ { dialog-window } append ] change-window-controls 
    open-window ;

TUPLE: navigation < pack ;
TUPLE: environment < tool ;
environment { 600 300 } set-tool-dim

INITIALIZED-SYMBOL: cnc-root [ vocab new "●" >>name ]

: <navigation> ( model -- navigation )
    navigation new swap >>model vertical >>orientation 1 >>fill
    resurface-panel
    ;

: <environment> ( -- gadget )
    cnc-root get <model> 
    vertical environment new-track over >>model
    swap <navigation> <scroller> 1 track-add 
;

: environment-window ( -- )
    [ <environment> "Resurface" open-window ] with-ui ; 

ALIAS: ew environment-window

: <navigation1> ( -- navigation )
    pack new vertical >>orientation 1 >>fill
    ;

: <environment1> ( -- gadget )
    vertical pack new-track 
;

: gadget-window ( -- )
    [ tool new "Factor Gadgets" open-window ] with-ui ; 

ALIAS: gw gadget-window 

! File: cnc.ui
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2023 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors arrays boids.simulation calendar classes
colors fonts kernel literals math math.functions
math.functions models models.range namespaces opengl
opengl.demo-support opengl.gl sequences threads ui ui.commands
ui.gadgets ui.gadgets.borders ui.gadgets.buttons
ui.gadgets.frames ui.gadgets.grids ui.gadgets.labeled
ui.gadgets.labels ui.gadgets.packs ui.gadgets.scrollers
ui.gadgets.sliders ui.gadgets.status-bar ui.gadgets.tracks
ui.gadgets.worlds ui.pixel-formats ui.render ui.tools.common ui.backend
vocabs ;
QUALIFIED-WITH: models.range mr
IN: cnc.ui

SYMBOLS: job-x job-y job-bit job-speed job-feed job-depth job-step ; 

TUPLE: cnc-gadget < gadget xmax ymax bit speed feed depth step ;

CONSTANT: initial-feed 1000
CONSTANT: initial-speed 10000
CONSTANT: initial-bit 25.4
CONSTANT: initial-depth 0.5
CONSTANT: initial-step 60

: <cnc-gadget> ( -- gadget )
    cnc-gadget new
    t >>clipped?
    ${ WIDTH HEIGHT } >>pref-dim
;

: <12-point-label-control> ( model -- gadget )
    <label-control> sans-serif-font 12 >>size >>font ;

TUPLE: range-observer quot ;

M: range-observer model-changed
    [ range-value ] dip quot>> call( value -- ) ;

: connect ( range-model quot -- )
    range-observer boa swap add-connection ;

<PRIVATE
: find-cnc-gadget ( gadget -- cnc-gadget )
    dup cnc-gadget? [ children>> [ cnc-gadget? ] find nip ] unless ;
PRIVATE>

:: cnc-panel ( cnc-gadget -- gadget )
    <pile> 
    2 2 <frame>
    { 4 4 } >>gap
    f >>fill?
    "speed" <label> { 0 0 } grid-add
    initial-speed 0 0 100 1 mr:<range>
    horizontal <slider> { 1 0 } grid-add

    "feed" <label> { 0 1 } grid-add
    initial-feed 0 1 100 1 mr:<range>
    horizontal <slider> { 1 1 } grid-add

    { 5 5 } <border> add-gadget
;
    ! "cnc" COLOR: dark-slate-grey <framed-labeled-gadget> ;

TUPLE: cnc-frame < pack ;

: <cnc-frame> ( -- cnc-frame )
    cnc-frame new  horizontal >>orientation
    <cnc-gadget>
    cnc-panel  { 5 5 } <border> add-gadget 
    ;

TUPLE: navigation < pack ;
TUPLE: environment < tool ;

environment { 600 300 } set-tool-dim

SYMBOL: cnc-root
vocab new "●" >>name cnc-root set-global

: <navigation> ( model -- navigation )
    navigation new swap >>model vertical >>orientation 1 >>fill
    cnc-panel ;

:: <environment> ( -- gadget )
    cnc-root get-global <model> :> model
    vertical environment new-track model >>model
    model <navigation> <scroller> 1 track-add
    ;

: environment-window ( -- )
    [ <environment>  white-interior  "CNC" open-window ] with-ui ; 

: environment-window1 ( -- )
    [ <environment>
      <world-attributes> 
      { windowed double-buffered multisampled
        T{ samples f 4 } T{ sample-buffers f 1 } }
      >>pixel-format-attributes        
      "CNC" >>title open-window ] with-ui ;

: ui-tools-main ( -- )
    t ui-stop-after-last-window? set-global
    environment-window ;

ALIAS: cncui ui-tools-main

MAIN-WINDOW: cnc { { title "CNC" } }
    <cnc-frame> >>gadgets ;

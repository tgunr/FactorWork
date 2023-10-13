! File: cnc.tools.resurface.ui
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors arrays boids.simulation calendar classes
colors fonts kernel literals math math.functions
math.functions models models.range namespaces opengl
opengl.demo-support opengl.gl sequences threads ui ui.commands
ui.gadgets ui.gadgets.borders ui.gadgets.buttons
ui.gadgets.frames ui.gadgets.grids ui.gadgets.labeled
ui.gadgets.labels ui.gadgets.packs ui.gadgets.scrollers
ui.gadgets.sliders ui.gadgets.status-bar ui.gadgets.tracks
ui.gadgets.worlds ui.pixel-formats ui.render ui.tools.common ui.backend
vocabs cnc.gcode cnc.bit cnc.tools ;

IN: cnc.tools.resurface.ui

QUALIFIED-WITH: models.range mr

CONSTANT: initial-feed 1000
CONSTANT: initial-speed 10000
CONSTANT: initial-bit 25.4
CONSTANT: initial-depth 0.5
CONSTANT: initial-step 60

TUPLE: resurface-gadget < gadget xmax ymax bitsize spindle speed feed step ;

:: resurface-panel ( cnc-gadget -- gadget )
    <pile> white-interior
    2 2 <frame>  { 4 4 } >>gap  syntax:f >>fill?
    
    "speed" <label> { 0 0 } grid-add
    initial-speed 0 0 100 1 mr:<range>

    
    horizontal <slider> { 1 0 } grid-add

    "feed" <label> { 0 1 } grid-add
    initial-feed 0 1 100 1 mr:<range>
    horizontal <slider> { 1 1 } grid-add

    { 5 5 } <border> add-gadget

    "Test" "red" named-color <framed-labeled-gadget> 
    ;

TUPLE: resurface-frame < pack ;

: <resurface-gadget> ( -- gadget )
    resurface-gadget new ;

: <resurface-frame> ( -- cnc-frame )
    resurface-frame new  horizontal >>orientation
    <resurface-gadget>
    resurface-panel
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

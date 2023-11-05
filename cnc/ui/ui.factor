! File: cnc.ui
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2023 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors arrays boids.simulation calendar classes colors
 fonts kernel literals math math.functions models
 models.range namespaces opengl opengl.demo-support opengl.gl sequences
 threads ui ui.backend ui.commands ui.gadgets ui.gadgets.borders
 ui.gadgets.buttons ui.gadgets.editors ui.gadgets.frames ui.gadgets.grids ui.gadgets.labeled ui.gadgets.labels
 ui.gadgets.packs ui.gadgets.scrollers ui.gadgets.sliders ui.gadgets.status-bar ui.gadgets.tracks ui.gadgets.worlds
 ui.gestures ui.pixel-formats ui.render ui.tools.common vocabs  ;
 
QUALIFIED-WITH: models.range mr
IN: cnc.ui

<PRIVATE

TUPLE: tabbing-editor < editor next-editor prev-editor ;

: <tabbing-editor> ( -- editor )
    tabbing-editor new-editor ;

TUPLE: tabbing-multiline-editor < multiline-editor next-editor prev-editor ;

: <tabbing-multiline-editor> ( -- editor )
    tabbing-multiline-editor new-editor ;

: com-prev ( editor -- )
    prev-editor>> [ request-focus ] when* ;

: com-next ( editor -- )
    next-editor>> [ request-focus ] when* ;

tabbing-editor tabbing-multiline-editor [
    "editing" f {
        { T{ key-down f f "TAB" } com-next }
        { T{ key-down f { S+ } "TAB" } com-prev }
    } define-command-map
] bi@

PRIVATE>

SYMBOLS: job-x job-y job-bit job-speed job-feed job-depth job-step ; 

TUPLE: cnc-gadget < track xmax ymax bit speed feed depth step ;

CONSTANT: initial-feed 1000
CONSTANT: initial-speed 10000
CONSTANT: initial-bit 25.4
CONSTANT: initial-depth 0.5
CONSTANT: initial-step 60

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

: <cnc-gadget> ( -- gadget )
    vertical cnc-gadget new-track
    0 >>fill
    { 10 10 } >>gap
    
    <pile> ! Create a container to hold all the elements

    2 2 <frame> ! Create a frame with a 2x2 grid layout
    { 4 4 } >>gap ! Set the gap between the elements in the grid
    f >>fill? ! Check if the frame should fill the available space
    "speed" <label> { 0 0 } grid-add ! Add a label with the text "speed" to the grid at position (0, 0)
    initial-speed 0 0 100 1 mr:<range> ! Add a range input with the value "initial-speed" and range from 0 to 100 with a step of 1
    horizontal <slider> { 1 0 } grid-add ! Add a horizontal slider to the grid at position (1, 0)
    "feed" <label> { 0 1 } grid-add ! Add a label with the text "feed" to the grid at position (0, 1)
    initial-feed 0 1 100 1 mr:<range> ! Add a range input with the value "initial-feed" and range from 0 to 100 with a step of 1
    horizontal <slider> { 1 1 } grid-add ! Add a horizontal slider to the grid at position (1, 1)
    { 5 5 } <border> ! Create a border with a size of 5x5
    add-gadget ! Add the border as a gadget to the frame

    add-gadget ! Add the frame as a gadget to the pile
;
    ! "cnc" COLOR: dark-slate-grey <framed-labeled-gadget> ;

: open-cnc-window ( -- )
    <cnc-gadget>  
    ${ WIDTH HEIGHT } >>pref-dim
    { 5 5 } <border> { 1 1 } >>fill
    white-interior
    "CNC" open-window  ;

ALIAS: cncui open-cnc-window

MAIN-WINDOW: cnc { { title "CNC" } }
    <cnc-gadget> >>gadgets ;

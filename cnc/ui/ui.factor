! File: cnc.ui
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2023 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs boids.simulation classes colors
 debugger fonts help.markup help.syntax kernel literals
 math math.parser math.rectangles models models.arrow models.mapping
 namespaces parser prettyprint prettyprint.config quotations sequences
 splitting strings ui ui.backend ui.commands ui.gadgets
 ui.gadgets.books ui.gadgets.borders ui.gadgets.buttons ui.gadgets.editors ui.gadgets.frames ui.gadgets.grids
 ui.gadgets.labels ui.gadgets.packs ui.gadgets.private ui.gadgets.sliders ui.gadgets.toolbar ui.gadgets.tracks
 ui.gadgets.worlds ui.gestures ui.private ui.text ui.tools.browser ui.tools.common
 ui.tools.deploy vocabs.loader vocabs.metadata  ;
 
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

CONSTANT: initial-feed 1000
CONSTANT: initial_spindle_speed 15000
CONSTANT: initial_bit_diameter 25.4
CONSTANT: initial_cut_depth 0
CONSTANT: initial_stepover 60

TUPLE: cnc-gadget < track settings
    { xmax initial: 1219.2 }
    { ymax initial: 812.8 }
    { zmax initial: -163.0 }
    { bit initial:  0.0635 }
    { speed initial: 15000 }
    { feed initial: 2500 }
    { depth initial: 0.1 }
    { stepover initial: 60 }
    ;

INITIALIZED-SYMBOL: gadget-position [ 0 ]
INITIALIZED-SYMBOL: start-position [ 2 ]

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

: default-config ( -- assoc )
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

: cnc-config-path ( vocab -- path/f )
    "cncui.factor" vocab-file-path ;

: cnc-config ( vocab -- assoc )
    [ default-config ] keep
    "cncui.factor" vocab-file-lines
    parse-fresh [ first assoc-union ] unless-empty  nip ;

: set-cnc-config ( assoc vocab -- )
    [ [ unparse-use ] without-limits split-lines ] dip
    "cncui.factor" set-vocab-file-lines ;

: set-cnc-flag ( value key vocab -- )
    [ cnc-config [ set-at ] keep ] keep set-cnc-config ;

: find-cnc-gadget ( gadget -- cnc-gadget )
    [ cnc-gadget? ] find-parent ;

: find-cnc-vocab ( gadget -- vocab )
    find-cnc-gadget class-of vocabulary>> ;

: find-cnc-config ( gadget -- config )
    find-cnc-vocab cnc-config ;

: find-cnc-settings ( gadget -- settings )
    find-cnc-gadget settings>> ;

: speed-field ( cnc-gadget gadget -- cnc-gadget gadget )
B    over speed>> <model-field>
    "Speed:" label-on-left add-gadget ;
    
: speed-pile ( gadget -- gadget )
    <pile> ! Create a container to hold all the elements
    3 2 <frame> ! Create a frame with a 2x2 grid layout
    { 4 4 } >>gap ! Set the gap between the elements in the grid
    f >>fill? ! Check if the frame should fill the available space

    "speed" <label> { 0 0 } grid-add ! Add a label with the text "speed" to the grid at position (0, 0)
    initial_spindle_speed 0 0 100 1 mr:<range> ! Add a range input with the value "initial-speed" and range from 0 to 100 with a step of 1
    horizontal <slider> { 1 0 } grid-add ! Add a horizontal slider to the grid at position (1, 0)
    "feed" <label> { 0 1 } grid-add ! Add a label with the text "feed" to the grid at position (0, 1)
    initial-feed 0 1 100 1 mr:<range> ! Add a range input with the value "initial-feed" and range from 0 to 100 with a step of 1
    horizontal <slider> { 1 1 } grid-add ! Add a horizontal slider to the grid at position (1, 1)
    { 5 5 } <border> ! Create a border with a size of 5x5
    add-gadget ! Add the border as a gadget to the frame
    add-gadget ! Add the frame as a gadget to the pile
    ; 

: cnc-settings ( parent -- gadget )
    ! "CNC Settings" <label> add-gadget
    ! start-position get  start-position-options <radio-buttons> add-gadget
    ;

: cnc-settings-theme ( gadget -- gadget )
    { 10 10 } >>gap  1 >>fill ;

: <cnc-settings> ( parent -- gadget )
    "cnc.ui" cnc-config [ <model> ]  assoc-map
    [ <pile> 
      swap speed>> <model-field>
      "Speed:" label-on-left add-gadget 
      cnc-settings-theme
      namespace <mapping> >>model
    ] with-variables ; 

: com-revert ( gadget -- )
    dup find-cnc-config
    swap find-cnc-settings set-control-value ;

: com-save ( gadget -- )
    dup find-cnc-settings control-value
    swap find-cnc-vocab set-cnc-config ;

: com-help ( -- )
    "cnc.ui" com-browse ;

\ com-help H{
    { +nullary+ t }
} define-command

: com-close ( gadget -- )
    close-window ;

cnc-gadget "misc" "Miscellaneous commands" {
    { T{ key-down f f "ESC" } com-close }
} define-command-map

cnc-gadget "toolbar" f {
    { T{ key-down f f "F1" } com-help }
    { f com-revert }
    { f com-save }
} define-command-map

: <cnc-gadget> ( -- gadget )
    cnc-gadget new  vertical >>orientation
    dup <cnc-settings> >>settings 
    dup settings>> add-gadget
    ! dup <toolbar> { 10 10 } >>gap add-gadget
    deploy-settings-theme
    dup com-revert ;    

: cnc-tool ( -- )
    <cnc-gadget> 
    ${ WIDTH HEIGHT } >>pref-dim
    { 5 5 } <border> { 1 1 } >>fill
    white-interior
    <world-attributes> "CNC" >>title
    [ { dialog-window } append ] change-window-controls
    open-window ;

ALIAS: cncui cnc-tool

MAIN-WINDOW: cnc { { title "CNC" } }
    <cnc-gadget> >>gadgets ;

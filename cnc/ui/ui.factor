! File: cnc.ui
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2023 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs boids.simulation classes fonts kernel
literals math math.parser models models.arrow models.mapping
namespaces parser prettyprint prettyprint.config sequences splitting
ui ui.commands ui.gadgets ui.gadgets.buttons
ui.gadgets.buttons.private ui.gadgets.editors ui.gadgets.frames
ui.gadgets.grids ui.gadgets.labels ui.gadgets.packs ui.gadgets.sliders
ui.gadgets.tracks ui.gadgets.worlds ui.gadgets.toolbar ui.gestures ui.pens.solid ui.theme
ui.tools.browser ui.tools.common ui.tools.deploy vocabs.metadata ;
 
IN: ui.gadgets.borders

TUPLE: colored-border < border { color initial: contents-color } ;

: <colored-border> ( child gap color -- border )
    [ colored-border new-border ] 2dip  [ >>size ] dip  <solid> >>interior  ;

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
    { speed initial: "15000" }
    { feed initial: 2500 }
    { depth initial: 0.1 }
    { stepover initial: 60 }
    { delay initial: "y" }
    { start-position initial: "Center" }
    { direction initial: "Horizontal" }
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

CONSTANT: direction-options { 
    { 1 "Horizontal" } 
    { 2 "Vertical" }
}

CONSTANT: delay-options { 
    { 1 "Y" } 
    { 2 "N" }
}

CONSTANT: units-options { 
    { 1 "inch" } 
    { 2 "mm" }
}

: build-frame ( -- frame )
    3 8 <frame>  { 4 4 } >>gap  syntax:f >>fill?  
    add-range-gadgets
;

SYMBOLS: job-units job-x job-y job-bit job-flutes job-speed job-feed job-depth job-step job-delay job-start-position job-direction job-chipload ;

: default-config ( -- assoc )
    H{
        { job-units 2 }
        { job-x "0" }
        { job-y "0" }
        { job-bit "1.125" }
        { job-flutes "2" }
        { job-speed "15000" }
        { job-feed "400" }
        { job-depth "0.0625" }
        { job-step "40" }   
        { job-delay t }
        { job-start-position "Lower Left" }
        { job-direction "Horizontal" }
        { job-chipload "0" }
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

: cnc-settings ( parent -- gadget )
    ! "CNC Settings" <label> add-gadget
    ! start-position get  start-position-options <radio-buttons> add-gadget
    ;

: cnc-settings-theme ( gadget -- gadget )
    { 10 10 } >>gap  1 >>fill ;

: units-setting ( track -- track )
    job-units get units-options
    <shelf>
    "Units: " <label> add-gadget
    [ <radio-button> ] <radio-controls>  { 5 5 } >>gap  f track-add
    ;

: xy-setting ( track -- track )
    horizontal track new-track
    job-x get <model-field> "X:" label-on-left 1/4 track-add
    job-y get <model-field> "Y:" label-on-left 1/4 track-add
    job-depth get <model-field> "Cut Depth:" label-on-left 1/4 track-add
    <gadget> 1/4 track-add
    f track-add
    ;

: bit-setting ( track -- track )
    horizontal track new-track
    job-bit get <model-field> "Bit Diameter:" label-on-left 1/4 track-add
    job-speed get <model-field> "Spindle Speed:" label-on-left 1/4 track-add
    job-flutes get <model-field> "Flutes:" label-on-left 1/4 track-add
    <gadget> 1/16 track-add
    job-delay get <model> "Delay:" <checkbox> 1/8 track-add
    f track-add
    ;

: feed-setting ( track -- track )
    horizontal track new-track
    job-feed get <model-field> "Feed Rate:" label-on-left 1/4 track-add
    job-step get <model-field> "Stepover %:" label-on-left 1/4 track-add
    <gadget> 1/4 track-add
    f track-add
    ;

: <cnc-settings> ( -- gadget )
    "cnc.ui" cnc-config [ <model> ]  assoc-map
    [ vertical track new-track
      units-setting
      xy-setting
      bit-setting
      feed-setting
      job-start-position get <model-field> "Start Position:" label-on-left f track-add
      job-direction get <model-field> "Direction:" label-on-left f track-add
      job-chipload get <model-field> "Chipload:" label-on-left f track-add
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

: <cnc-gadget> ( -- cnc-gadget )
    vertical cnc-gadget new-track with-lines
    <cnc-settings> >>settings 
    dup settings>> f track-add
    add-toolbar
    deploy-settings-theme
    dup com-revert ;    

: cnc-tool ( -- )
    <cnc-gadget>  
    ! { 15 15 } <border> { 1 1 } >>fill
    white-interior
    <world-attributes> "CNC" >>title
    ${ WIDTH HEIGHT } >>pref-dim
    ! [ { dialog-window } append ] change-window-controls
    open-window ;

ALIAS: cncui cnc-tool

MAIN-WINDOW: cnc { { title "CNC" } }
    <cnc-gadget> >>gadgets ;

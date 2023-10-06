! File: ui.theme.tango
! Version: 0.1
! DRI: Dave Carlton
! Description: Tango theme
! Copyright (C) 2022 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: colors namespaces ui.theme ui.theme.switching ;
IN: ui.theme.tango

SINGLETON: tango-light
theme [ tango-light ] initialize

M: tango-light toolbar-background COLOR: grey95 ;
M: tango-light toolbar-button-pressed-background COLOR: dark-gray ;

M: tango-light menu-background COLOR: grey95 ;
M: tango-light menu-border-color COLOR: grey75 ;

M: tango-light status-bar-background COLOR: FactorDarkSlateBlue ;
M: tango-light status-bar-foreground COLOR: white ;

M: tango-light button-text-color COLOR: FactorDarkSlateBlue ;
M: tango-light button-clicked-text-color COLOR: white ;

M: tango-light line-color COLOR: grey75 ;

M: tango-light column-title-background COLOR: grey95 ;

M: tango-light roll-button-rollover-border COLOR: gray50 ;
M: tango-light roll-button-selected-background COLOR: dark-gray ;

M: tango-light source-files-color COLOR: MediumSeaGreen ;
M: tango-light errors-color COLOR: chocolate1 ;
M: tango-light details-color COLOR: SteelBlue3 ;

M: tango-light debugger-color COLOR: chocolate1 ;
M: tango-light completion-color COLOR: magenta ;

M: tango-light data-stack-color COLOR: DodgerBlue ;
M: tango-light retain-stack-color COLOR: HotPink ;
M: tango-light call-stack-color COLOR: GreenYellow ;

M: tango-light title-bar-gradient { COLOR: white COLOR: grey90 } ;

M: tango-light popup-color COLOR: yellow2 ;

M: tango-light object-color COLOR: aquamarine2 ;
M: tango-light contents-color COLOR: orchid2 ;

M: tango-light help-header-background COLOR: #F4EFD9 ;

M: tango-light thread-status-stopped-background COLOR: #F4D9D9 ;
M: tango-light thread-status-suspended-background COLOR: #F4EAD9 ;
M: tango-light thread-status-running-background COLOR: #EDF4D9 ;

M: tango-light thread-status-stopped-foreground COLOR: #F42300 ;
M: tango-light thread-status-suspended-foreground COLOR: #F37B00 ;
M: tango-light thread-status-running-foreground COLOR: #3FCA00 ;

M: tango-light error-summary-background COLOR: #F4D9D9 ;

M: tango-light content-background COLOR: white ;
M: tango-light text-color COLOR: black ;

M: tango-light link-color COLOR: #2A5DB0 ;
M: tango-light title-color COLOR: gray20 ;
M: tango-light heading-color COLOR: FactorDarkSlateBlue ;
M: tango-light snippet-color COLOR: DarkOrange4 ;
M: tango-light output-color COLOR: DarkOrange4 ;
M: tango-light deprecated-background-color COLOR: #F4EAD9 ;
M: tango-light deprecated-border-color COLOR: #F37B00 ;
M: tango-light warning-background-color COLOR: #F4D9D9 ;
M: tango-light warning-border-color COLOR: #F42300 ;
M: tango-light code-background-color COLOR: FactorLightTan ;
M: tango-light code-border-color COLOR: FactorTan ;
M: tango-light help-path-border-color COLOR: grey95 ;

M: tango-light tip-background-color COLOR: lavender ;

M: tango-light prompt-background-color T{ rgba f 1 0.7 0.7 1 } ;

M: tango-light dim-color COLOR: gray35 ;
M: tango-light highlighted-word-color COLOR: DarkSlateGray ;
M: tango-light string-color COLOR: LightSalmon4 ;
M: tango-light stack-effect-color COLOR: FactorDarkSlateBlue ;

M: tango-light field-border-color COLOR: gray ;

M: tango-light editor-caret-color COLOR: red ;
M: tango-light selection-color T{ rgba f 0.8 0.8 1.0 1.0 } ;
M: tango-light panel-background-color T{ rgba f 0.7843 0.7686 0.7176 1.0 } ;
M: tango-light focus-border-color COLOR: dark-gray ;

M: tango-light labeled-border-color COLOR: grey85 ;

M: tango-light table-border-color COLOR: FactorTan ;

SINGLETON: tango-dark
theme [ tango-dark ] initialize

M: tango-dark toolbar-background COLOR: #2e3436 ;
M: tango-dark toolbar-button-pressed-background COLOR: solarized-base0 ;

M: tango-dark menu-background COLOR: #2e3436 ;
M: tango-dark menu-border-color COLOR: solarized-base01 ;

M: tango-dark status-bar-background COLOR: FactorDarkSlateBlue ;
M: tango-dark status-bar-foreground COLOR: white ;

M: tango-dark button-text-color COLOR: solarized-base1 ;
M: tango-dark button-clicked-text-color COLOR: white ;

M: tango-dark line-color COLOR: solarized-base01 ;

M: tango-dark column-title-background COLOR: #2e3436 ;

M: tango-dark roll-button-rollover-border COLOR: gray50 ;
M: tango-dark roll-button-selected-background COLOR: #2e3436 ;

M: tango-dark source-files-color COLOR: solarized-green ;
M: tango-dark errors-color COLOR: solarized-red ;
M: tango-dark details-color COLOR: solarized-blue ;

M: tango-dark debugger-color COLOR: solarized-red ;
M: tango-dark completion-color COLOR: solarized-violet ;

M: tango-dark data-stack-color COLOR: solarized-blue ;
M: tango-dark retain-stack-color COLOR: solarized-magenta ;
M: tango-dark call-stack-color COLOR: solarized-green ;

M: tango-dark title-bar-gradient { COLOR: solarized-base01 COLOR: solarized-base02 } ;

M: tango-dark popup-color COLOR: solarized-yellow ;

M: tango-dark object-color COLOR: solarized-cyan ;
M: tango-dark contents-color COLOR: solarized-magenta ;

M: tango-dark help-header-background COLOR: #2e3436 ;

M: tango-dark thread-status-stopped-background COLOR: #492d33 ;
M: tango-dark thread-status-suspended-background COLOR: #2e3436 ;
M: tango-dark thread-status-running-background COLOR: #2c4f24 ;

M: tango-dark thread-status-stopped-foreground COLOR: solarized-red ;
M: tango-dark thread-status-suspended-foreground COLOR: solarized-yellow ;
M: tango-dark thread-status-running-foreground COLOR: solarized-green ;

M: tango-dark error-summary-background COLOR: #6E2E32 ;

M: tango-dark content-background COLOR: #2e3436 ;
M: tango-dark text-color COLOR: #b0f566 ;

M: tango-dark link-color COLOR: #8ab4f8 ;
M: tango-dark title-color COLOR: grey75 ;
M: tango-dark heading-color COLOR: grey75 ;
M: tango-dark snippet-color COLOR: solarized-orange ;
M: tango-dark output-color COLOR: solarized-orange ;
M: tango-dark deprecated-background-color COLOR: #3c4a24 ;
M: tango-dark deprecated-border-color COLOR: solarized-yellow ;
M: tango-dark warning-background-color COLOR: #492d33 ;
M: tango-dark warning-border-color COLOR: solarized-red ;
M: tango-dark code-background-color COLOR: #2F4D5B ;
M: tango-dark code-border-color COLOR: #666666 ;
M: tango-dark help-path-border-color COLOR: solarized-base02 ;

M: tango-dark tip-background-color COLOR: #2F4D5B ;

M: tango-dark prompt-background-color COLOR: #922f31 ;

M: tango-dark dim-color COLOR: solarized-cyan ;
M: tango-dark highlighted-word-color COLOR: solarized-green ;
M: tango-dark string-color COLOR: solarized-magenta ;
M: tango-dark stack-effect-color COLOR: solarized-orange ;

M: tango-dark field-border-color COLOR: solarized-base01 ;

M: tango-dark editor-caret-color COLOR: DeepPink2 ;
M: tango-dark selection-color COLOR: solarized-base01 ;
M: tango-dark panel-background-color T{ rgba f 0.7843 0.7686 0.7176 1.0 } ;
M: tango-dark focus-border-color COLOR: solarized-base01 ;

M: tango-dark labeled-border-color COLOR: solarized-base01 ;

M: tango-dark table-border-color COLOR: solarized-base01 ;

IN: ui.theme.switching
: tango-light-mode ( -- ) tango-light switch-theme ;
: tango-dark-mode ( -- ) tango-dark switch-theme ;


! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors ascii assocs fonts help.apropos help.home help.topics
io kernel math models namespaces openai sequences ui.gadgets
ui.gadgets.editors ui.gadgets.status-bar ui.gadgets.tracks
ui.gadgets.worlds ui.text ui.tools.browser ui.tools.browser.history
ui.tools.listener ui.tools.common urls webbrowser wrap ;

IN: wrap.strings
: listener-wrap-string ( string -- 'string )
    listener-gadget get-tool-dim first 
    monospace-font " " text-width >integer /  wrap ;

IN: davec.openai 

"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" openai-api-key set-global

TUPLE: gpt-gadget < browser-gadget ;

: models-url ( -- )
    URL" https://platform.openai.com/docs/models/overview" open-url ;

: test ( -- )
    "gpt-4-0314"
    "what is the factor programming language"
    <completion> 100 >>max_tokens create-completion
    "choices" of first "text" of print ;


: >q ( question -- )
    "gpt-4-0314"
    swap <completion> 1000 >>max_tokens create-completion
    "choices" of first "text" of  wrap print ; 

: show ( link browser-gadget -- )
    [ >link ] dip [
        2dup control-value =
        [ 2drop ]
        [ [ add-recent ] [ history>> add-history ] bi* ] if
    ] [ set-control-value ] 2bi ;

: ask ( string browser -- )
    [ [ [ blank? ] trim <apropos-search> ] ] dip
    [ show ] curry compose unless-empty ;

: <ask-field> ( window -- field )
    [ ask ] curry
    <action-field> "Ask" >>default-text 10 >>min-cols
    10 >>max-cols white-interior ;

: <gpt-gadget> ( -- gadget )
    vertical gpt-gadget  new-track with-lines  1 >>fill
    "" >link <model> >>model
    dup <history> >>history
    dup <ask-field> >>search-field
    add-help-pane  add-help-footer ;

: gpt-new ( -- )
    <gpt-gadget> <world-attributes> "GPT" >>title
    open-status-window ;


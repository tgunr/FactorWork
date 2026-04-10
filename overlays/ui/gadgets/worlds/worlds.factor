USING: accessors assocs cache colors combinators
combinators.short-circuit concurrency.promises continuations
destructors kernel literals math models namespaces opengl
sequences strings ui.backend ui.gadgets ui.gadgets.tracks
ui.gestures ui.pixel-formats ui.render ui.private ;
IN: ui.gadgets.worlds

: find-world-titled ( title -- world|f )
    worlds get  swap [ swap  second title>> = ] curry find
    over boolean?
    [ drop ]
    [ nip  second ] if ; 


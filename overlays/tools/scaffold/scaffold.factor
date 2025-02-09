! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien arrays assocs byte-arrays calendar
classes classes.error combinators combinators.short-circuit
continuations effects eval hashtables help.markup interpolate io
io.directories io.encodings.utf8 io.files io.pathnames
io.streams.string kernel math math.parser namespaces parser
prettyprint prettyprint.config quotations sequences sets sorting
splitting strings system timers unicode urls vocabs
vocabs.loader vocabs.metadata words words.symbol ;
IN: tools.scaffold

: scaffold-overlays ( string -- )
    "resource:overlays" swap scaffold-vocab-in  ;

: scaffold-factorwork ( string -- )
    "/Users/davec/factorwork" swap scaffold-vocab-in  ;

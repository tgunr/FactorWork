! Copyright (C) 2005, 2010 Slava Pestov.
! Copyright (C) 2008 Eduardo Cavazos.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.syntax byte-arrays
combinators.short-circuit combinators.smart generalizations kernel
libc math sequences sequences.generalizations strings system
unix.ffi vocabs.loader ;
IN: unix

: truncate-file ( path n -- ) [ truncate ] unix-system-call drop ;


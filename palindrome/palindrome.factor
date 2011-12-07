! Copyright (C) 2011 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences math ;
IN: palindrome

USE: palindrome

: palindrome? ( string -- ? ) dup reverse = ;
: par ( r1 r2 -- r )  2dup * -rot + / ;
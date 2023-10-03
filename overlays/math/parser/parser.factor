USING: accessors byte-arrays combinators kernel kernel.private
layouts make math math.private sbufs sequences sequences.private
strings ;
IN: math.parser

: >number ( n|string -- n )
    dup string? [ string>number ] when ;

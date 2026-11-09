! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math.parser multiline peg peg.ebnf ;
IN: cnc.gcode.parser

! <program>        ::= {<line>}
! <line>           ::= <command> <parameters> '\n'
! <command>        ::= 'G0' | 'G1'
! <parameters>     ::= {<parameter>}
! <parameter>      ::= <axis_parameter> | <feedrate_parameter>
! <axis_parameter> ::= ('X' | 'Y' | 'Z') <number>
! <feedrate_parameter> ::= 'F' <number>
! <number>         ::= <digit> { <digit> } [ '.' { <digit> } ]
! <digit>          ::= '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9'

EBNF: gtoken [=[
line = command                  
space = (" " | "\r" | "\t" | "\n")
spaces = space* => [[ drop ignore ]]
number = ([0-9])+         => [[ string>number ]]
command = "G0" | "G1"                   
]=]


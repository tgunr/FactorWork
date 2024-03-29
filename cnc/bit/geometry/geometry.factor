! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors db.tuples db.types kernel math.parser sequences
splitting sequences.strings syntax.terse
cnc
cnc.db
cnc.bit ;
IN: cnc.bit.geometry

TUPLE: bit-geometry name tool_type units diameter shank notes amanaid id ;
bit-geometry "bit_geometry" {
    { "name" "name_format" TEXT }
    { "tool_type" "tool_type" INTEGER }
    { "units" "units" INTEGER }
    { "diameter" "diameter" DOUBLE }
    { "shank" "shank" TEXT }
    { "notes" "notes" TEXT }
    { "amanaid" "amanaid" TEXT }
    { "id" "id" TEXT +user-assigned-id+ +not-null+ }
} define-persistent

FROM: help.syntax.private => trim-whitespace ; 
: convert-bit-geometry ( bit -- bit )
    [ name>> ] retain  " " split  unclip  dup unclip
    CHAR: # =
    [ drop  [ " " join  trim-whitespace  >>name ] dip  >>amanaid ]
    [ 3drop ]
    if
    [ tool_type>> ] retain  >number >>tool_type
    [ diameter>> ] retain  >number  >>diameter 
    [ units>> ] retain  >number  >>units 
    ;

: bit-geometery-table-drop ( -- )
    "DROP TABLE IF EXISTS bit_geometery"
    clean-whitespace  do-cncdb 2drop ;

: bit-geometery-table-create ( -- )
  "CREATE TABLE IF NOT EXISTS bit_geometery (
  'name' text NOT NULL,
  'tool_type' integer NOT NULL,
  'units' integer NOT NULL DEFAULT(0),
  'diameter' real,
  'notes' text,
  'id' text PRIMARY KEY UNIQUE NOT NULL,
  'amana_id' text )"        
   clean-whitespace  do-cncdb 2drop ;

: bit-geometry-id= ( id -- bit )
    bit-geometry new  swap hard-quote >>id
    [ select-tuple ] with-cncdb ; 


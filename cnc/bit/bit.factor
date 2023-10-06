! File: cnc.bit
! Version: 0.1
! DRI: Dave Carlton
! Description: CNC bit data
! Copyright (C) 2022 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.enums assocs classes.tuple cnc cnc.db
combinators db db.tuples db.types io kernel math math.parser
namespaces prettyprint sequences splitting strings syntax.terse ;
IN: cnc.bit

SYMBOL: amanavt-db-path amanavt-db-path [ "/Users/davec/Dropbox/3CL/Data/amanavt.db" ] initialize
SYMBOL: imperial-db-path imperial-db-path [ "/Users/davec/Desktop/Imperial.db" ]  initialize

SYMBOL: BitType 
BitType [ { "straight" "upcut" "downcut" "compression" } ] initialize

SYMBOL: ToolType 
ToolType [ { "ballnose" "endmill" "radius-endmill" "v-bit" "engraving" "taper-ballmill"
    "drill" "diamond" "groove" "threadmill"  "multit-thread"  "laser" } <enumerated> ] initialize

SYMBOL: RateUnits 
RateUnits [ { "mm/sec" "mm/min" "m/min" "in/sec" "in/min" "ft/min" } <enumerated> ] initialize

SYMBOL: DimUnits 
DimUnits [ { "mm" "in" } <enumerated> ] initialize

: enum@ ( key symbol -- value )
    get  value-at ; 
: @enum ( value symbol -- key )
    get  at ; 

! TUPLES
TUPLE: bit name units tool_type bit_type diameter stepdown stepover spindle_speed spindle_dir
    flutes shank flute_length shank_length 
    rate_units feed_rate plunge_rate
    cost make model source id amana_id entity_id ;

bit "bits" {
    { "name" "name" TEXT }
    { "units" "units" INTEGER }
    { "tool_type" "tool_type" INTEGER }
    { "bit_type" "bit_type" INTEGER }
    { "diameter" "diameter" DOUBLE }
    { "stepdown" "stepdown" DOUBLE }
    { "stepover" "stepover" DOUBLE }
    { "spindle_speed" "spindle_speed" INTEGER }
    { "spindle_dir" "spindle_dir" INTEGER }
    { "flutes" "flutes" INTEGER }
    { "shank" "shank" DOUBLE }
    { "flute_length" "flute_length" DOUBLE }
    { "shank_length" "shank_length" DOUBLE }
    { "rate_units" "rate_units" INTEGER }
    { "feed_rate" "feed_rate" DOUBLE }
    { "plunge_rate" "plunge_rate" DOUBLE }
    { "cost" "cost" DOUBLE }
    { "make" "make" TEXT }
    { "model" "model" TEXT }
    { "source" "source" TEXT }
    { "id" "id" TEXT +user-assigned-id+ +not-null+ }
    { "amana_id" "amana_id" TEXT }
    { "entity_id" "entity_id" TEXT }
} define-persistent 

    
: <bit> ( -- <bit> )
    bit new  
    "mm" DimUnits enum@ >>units  
    "endmill" ToolType enum@ >>tool_type  
    "upcut" BitType enum@ >>bit_type
    18000 >>spindle_speed  
    0 >>spindle_dir 
    2 >>flutes  
    "mm/min" RateUnits enum@ >>rate_units  
    quintid >>id  ;

: sql>bit ( bit -- bit )
    [ name>> ] retain  " " split  unclip  dup unclip
    CHAR: # =
    [ drop  [ " " join  trim-whitespace  >>name ] dip  >>amana_id ]
    [ 3drop ]
    if
    [ tool_type>> ] retain >number >>tool_type
    [ bit_type>> ] retain >number >>bit_type
    [ diameter>> ] retain  >number  >>diameter 
    [ units>> ] retain  >number  >>units 
    [ feed_rate>> ] retain  >number  >>feed_rate 
    [ rate_units>> ] retain  >number >>rate_units 
    [ plunge_rate>> ] retain  >number  >>plunge_rate 
    [ spindle_speed>> ] retain  >number  >>spindle_speed 
    [ spindle_dir>> ] retain  >number  >>spindle_dir 
    [ stepdown>> ] retain  >number  >>stepdown 
    [ stepover>> ] retain  >number  >>stepover 
    ;

: bit>sql ( bit -- bit )
    [ units>> ] retain enum>number >>units
    [ tool_type>> ] retain enum>number >>tool_type
    [ bit_type>> ] retain  enum>number  >>bit_type
    [ rate_units>> ] retain  enum>number  >>rate_units ;

: cncdb>bit ( cnc-dbvt -- bit )
    bit slots>tuple sql>bit ;

: (inch>mm) ( bit inch -- bit mm )
    over units>> 1 = [ 25.4 / ] when ;

: >>diameter-mm ( object value -- object )   (inch>mm) >>diameter ;
: >>stepover-mm ( object value -- object )   (inch>mm) >>stepover ;
: >>stepdown-mm ( object value -- object )   (inch>mm)  >>stepdown ;
: >>feed_rate-mm/min ( object value -- object )  25.4 * >>feed_rate  1 >>rate_units ; 
: >>plunge_rate-mm/min ( object value -- object )  25.4 * >>plunge_rate  1 >>rate_units ; 

: (>mm) ( bit slot-value -- mm-value bit )
    over units>> 1 = 
    [ >number 25.4 * ] when
    >number swap
    ;

: (>mm/min) ( bit value -- mm-value bit )
    >number  over rate_units>> >number  RateUnits @enum 
    { 
        { "mm/sec" [ 60 * ] }
        { "mm/min" [ ] }
        { "m/min" [ 1000 * ] }
        { "in/sec" [ 25.4 * 60 * ] }
        { "in/min" [ 25.4 * ] }
        { "ft/min" [ 304.8 * ] }
    } case  swap ;
    
: >mm ( bit -- bit )
    [ dup diameter>> (>mm) diameter<< ] keep
    [ dup feed_rate>> (>mm/min) feed_rate<< ] keep
    [ dup plunge_rate>> (>mm/min) plunge_rate<< ] keep
    [ dup stepdown>> (>mm) stepdown<< ] keep
    [ dup stepover>> (>mm) stepover<< ] keep
    "mm/min" RateUnits enum@ >>rate_units
    "mm" DimUnits enum@ >>units 
    ;

: .bit ( bit -- )
    bit new
    over name>> >>name 
    over units>> DimUnits @enum  >>units 
    over tool_type>> ToolType @enum >>tool_type
    over bit_type>> BitType @enum >>bit_type
    over diameter>>  >>diameter 
    over stepdown>>  >>stepdown 
    over stepover>>  >>stepover
    over spindle_speed>> >>spindle_speed 
    over spindle_dir>> >>spindle_dir 
    over flutes>> >>flutes
    over shank>> >>shank
    over shank>> >>shank
    over flute_length>> >>flute_length
    over shank_length>> >>shank_length
    over rate_units>> RateUnits @enum >>rate_units 
    over feed_rate>> >>feed_rate 
    over plunge_rate>> >>plunge_rate 
    over cost>> >>cost 
    over make>> >>make
    over model>> >>model
    over source>> >>source
    over id>> >>id
    over amana_id>> >>amana_id
    over entity_id>> >>entity_id
    nip pprint nl
;

: cnc-db>bit ( cnc-dbvt -- bit )
    bit slots>tuple sql>bit ;

: do-bitdb ( statement -- result ? )
    do-cncdb
    [ f ] [ [ cnc-db>bit ] map t ] if ;

: bit-table-drop ( -- )
    "DROP TABLE IF EXISTS bits"
    clean-whitespace  do-cncdb 2drop ;

: bit-table-create ( -- )
  "CREATE TABLE IF NOT EXISTS 'bits' (
  'name' text NOT NULL,
  'tool_type' integer NOT NULL,
  'units' integer NOT NULL DEFAULT(0),
  'diameter' real,
  'stepdown' real,
  'stepover' real,
  'spindle_speed' integer,
  'spindle_dir' integer,
  'rate_units' integer  NOT NULL,
  'feed_rate' real,
  'plunge_rate' real,
  'id' text PRIMARY KEY UNIQUE NOT NULL,
  'amana_id' text )"        
   clean-whitespace  do-cncdb 2drop ;

: cncdb-where ( -- sql )
    "SELECT * FROM bits WHERE " clean-whitespace ;
    
: bit-where-clause ( clauses -- 'claues )
    dup length 1 > 
    [ [ " and " append ] map 
    "" swap [ append ] each
      "id not null" append
    ]
    [ "" swap [ append ] each ]
    if 
    cncdb-where prepend ;

: bit-add ( bit -- )
    tuple>array  unclip drop 
    "INSERT OR REPLACE INTO bits VALUES (" swap ! )
    [ dup string? [ hard-quote ] when
      dup ratio? [ 1.0 * ] when 
      dup number? [ number>string ] when
      dup [ drop "NULL" ] unless
      ", " append  append
    ] each
    unclip-last drop  unclip-last drop 
    ");" append  do-cncdb 2drop ; 

: bit-delete ( bit -- )
    "DELETE FROM bits WHERE id = '"
    over id>> append  "'" append
    sql-statement set
    [ sql-statement get sql-query ] with-cncdb
    2drop ;
                                
: bit-where ( clauses -- seq )
    bit-where-clause do-bitdb drop ;

: bit-name-like ( named --  bit )
    hard-quote
    "name LIKE " prepend { } 1sequence bit-where ;

: bit-id= ( string -- bit )
    hard-quote  "id = "  prepend
    cncdb-where prepend  do-bitdb
    [ first ] [ drop f ] if ; 

: 1/4-bits ( -- bits )
    { "diameter = 0.25" "units = 1" } bit-where ;

: 1/8bits ( -- bits )
    { "diameter = 0.125" "units = 1" } bit-where ;

: metric-bits ( -- bits ) 
    { "units = 0" } bit-where ;

: imperial-bits ( -- bits )
    { "units = 0" } bit-where ;

: all-bits ( -- bits )
    { "id NOT NULL" } bit-where ;

: spoil-bits ( -- bits )
    { "name LIKE '%SPOIL%1/4\"SHANK'" } bit-where ;

: update-bit ( -- ) 
;

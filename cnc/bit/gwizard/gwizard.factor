! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors classes.tuple db db.sqlite io.encodings.utf8 kernel
namespaces sequences csv math cnc.bit cnc.bit.vcarve ;
IN: cnc.bit.gwizard

SYMBOL: gw-csv-path gw-csv-path [ "/Users/davec/icloud/3CL/Data/gwizard.csv" ]  initialize
SYMBOL: gw-db-path gw-db-path [ "/Users/davec/icloud/3CL/Data/gw.sqlite" ]  initialize

TUPLE: gwdb < sqlite-db ;
: <gw> ( -- gwdb )
    gwdb new  gw-db-path get >>path ;

: with-gwdb ( quot: ( gwdb -- ) -- )
    '[ <gw> _ with-db ] call ; inline

TUPLE: gw-csv slot description serialno tool generic geometry flutes 
    leadang diameter stickout cutLength overallLength shankSize 
    noseRad helixAngle coating toolmaterial toolFamily vendor product 
    idNo insNo sfm ipt chipload useMfgSFM mfgSFM useMfgIPT mfgIPT 
    xcomp zcomp xgeom zgeom status quantity 
    field1 field2 field3 field4 units 
    holderType holderDesc holderDia holderLen 
    comment clockwise coolantMode coolantSupport 
    shoulderLength taperAngle2 threadPitch 
    tipLength tipDiameter productLink jobCode pricePaid ;
! TUPLE: gw-csv { slot integer } description { serialno integer } tool generic geometry { flutes integer } { leadang integer } { diameter integer } { stickout integer } { cutLength integer } { overallLength integer } { shankSize integer } { noseRad integer } { helixAngle integer } coating toolmaterial toolFamily vendor product { idNo integer } { insNo integer } { sfm integer } { ipt integer } { chipload integer } useMfgSFM { mfgSFM integer } { useMfgIPT integer } { mfgIPT integer } { xcomp integer } { zcomp integer } { xgeom integer } { zgeom integer } status { quantity integer } field1 field2 field3 field4 units holderType holderDesc { holderDia integer } { holderLen integer } comment clockwise coolantMode coolantSupport { shoulderLength integer } { taperAngle2 integer } { threadPitch integer } { tipLength integer } { tipDiameter integer } productLink jobCode { pricePaid float } ;
! slot,description,serialno,tool,generic,geometry,flutes,leadang,diameter,stickout,cutLength,overallLength,shankSize,noseRad,helixAngle,coating,toolmaterial,toolFamily,vendor,product,idNo,insNo,sfm,ipt,chipload,useMfgSFM,mfgSFM,useMfgIPT,mfgIPT,xcomp,zcomp,xgeom,zgeom,status,quantity,field1,field2,field3,field4,units,holderType,holderDesc,holderDia,holderLen,comment,clockwise,coolantMode,coolantSupport,shoulderLength,taperAngle2,threadPitch,tipLength,tipDiameter,productLink,jobCode,pricePaid

! map a csv row to a gwdb tuple
: gwcsv>bit ( gwcsv -- bit )
    bit new 
    over description>> >>name  
    over units>> >>units
    over tool>> >>tool_type  
    over geometry>> >>bit_type  
    over diameter>> >>diameter  
    over diameter>> >>stepdown
    over stepover>> >>stepover
    over stepover>> >>spindle_speed
    over stepover>> >>spindle_dir
    over flutes>> >>flutes  
    over stepover>> >>shank
    over stepover>> >>flute_length
    over stepover>> >>shank_length
    over stepover>> >>rate_units
    over stepover>> >>feed_rate
    over stepover>> >>plunge_rate
    over stepover>> >>cost
    over stepover>> >>model
    over stepover>> >>source
    over stepover>> >>id
    over stepover>> >>amana_id
    over stepover>> >>entity_id
    nip 
    ;

: gwcsv>gwdb ( -- gwdb )
    gw-csv-path get utf8 file>csv
    unclip drop
    [ \ gw-csv prefix  >tuple ] map
    ;

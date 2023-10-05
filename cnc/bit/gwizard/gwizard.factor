! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors classes.tuple db db.sqlite io.encodings.utf8 kernel
namespaces sequences csv math cnc.bit.vcarve ;
IN: cnc.bit.gwizard

SYMBOL: gw-csv-path gw-csv-path [ "/Users/davec/icloud/3CL/Data/gwizard.csv" ]  initialize
SYMBOL: gw-db-path gw-db-path [ "/Users/davec/icloud/3CL/Data/gw.sqlite" ]  initialize

TUPLE: gwdb < sqlite-db ;
: <gw> ( -- gwdb )
    gwdb new  gw-db-path get >>path ;

: with-gwdb ( quot: ( gwdb -- ) -- )
    '[ <gw> _ with-db ] call ; inline

TUPLE: gw-csv slot description serialno tool generic geometry flutes leadang diameter stickout cutLength overallLength shankSize noseRad helixAngle coating toolmaterial toolFamily vendor product idNo insNo sfm ipt chipload useMfgSFM mfgSFM useMfgIPT mfgIPT xcomp zcomp xgeom zgeom status quantity field1 field2 field3 field4 units holderType holderDesc holderDia holderLen comment clockwise coolantMode coolantSupport shoulderLength taperAngle2 threadPitch tipLength tipDiameter productLink jobCode pricePaid ;
! TUPLE: gw-csv { slot integer } description { serialno integer } tool generic geometry { flutes integer } { leadang integer } { diameter integer } { stickout integer } { cutLength integer } { overallLength integer } { shankSize integer } { noseRad integer } { helixAngle integer } coating toolmaterial toolFamily vendor product { idNo integer } { insNo integer } { sfm integer } { ipt integer } { chipload integer } useMfgSFM { mfgSFM integer } { useMfgIPT integer } { mfgIPT integer } { xcomp integer } { zcomp integer } { xgeom integer } { zgeom integer } status { quantity integer } field1 field2 field3 field4 units holderType holderDesc { holderDia integer } { holderLen integer } comment clockwise coolantMode coolantSupport { shoulderLength integer } { taperAngle2 integer } { threadPitch integer } { tipLength integer } { tipDiameter integer } productLink jobCode { pricePaid float } ;

: gwcsv>gwdb ( -- gwdb )
    gw-csv-path get utf8 file>csv
    unclip drop
    [ \ gw-csv prefix  >tuple ] map
    ;

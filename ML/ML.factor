! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes.tuple folder images.loader io.directories
 io.files io.pathnames json json.prettyprint kernel namespaces folder.collection
 sequences string  ;
IN: ML

TUPLE: ml-coordinate y width x height ;

TUPLE: ml-annotation  label coordinates ;
C: <ml-annotation> ml-annotation

TUPLE: ml-image path annotations ;
C: <ml-image> ml-image

TUPLE: Annotation is_crowd category_id id image_id bbox area ;
TUPLE: Category supercategory name id ;
TUPLE: Image id height file_name license width ;

SYMBOL: Annotations
SYMBOL: Categories
SYMBOL: Images
SYMBOL: ML-Images 

: mlinit ( -- )
    "/Users/davec/Work/MLAnnotations/mvtec_screws.json" path>json
B    "annotations" over at [ values \ Annotation prefix >tuple ] map 
    Annotations set
    "categories" over at [ values \ Category prefix >tuple ] map
    Categories set 
    "images" swap at  [ values \ Image prefix >tuple ] map
    Images set
    ;

:: annotation>ml ( annotation -- )
    [ ] :> annos!  
    Images get [ id>> annotation image_id>> = ] filter 
    first file_name>> :> iname

    annotation bbox>> :> abox!
    4 abox remove-nth  \ ml-coordinate prefix >tuple  :> mlc

    annotation category_id>> :> catid
    Categories get [ id>> catid = ] filter
    first name>> :> mllabel

    annos mlc mllabel ml-annotation boa suffix  annos!
    ML-Images get
    annos "images/" iname append  ml-image boa  suffix
    ML-Images set
    ;

: annotations>ML ( -- )
    { } ML-Images set  Annotations get
    [ annotation>ml ] each
    ML-Images get  "/Users/davec/Work/MLAnnotations/ML.json" pprint-json>path
    ;

: image-coordinates ( entry -- ml-coordinate )
    pathname>> load-image
    dim>>  first2  swap  0 -rot  0 swap  ml-coordinate boa
    ;

SYMBOL: COINS-FOLDER
SYMBOL: ML-FOLDER
SYMBOL: IMAGE-FOLDER
SYMBOL: ANNOTATIONS

: ml-folder ( -- path )
    ML-FOLDER get  "/images" append ;

: make-image-folder ( -- entry )
    ml-folder dup  file-exists?
    [ dup make-directory  ] unless
    >folder 
    ;

: image-copy ( entry -- )
     make-image-folder entry-copy ;

: label-box ( entry label -- ml-image )
    { }  [ dup image-coordinates ] 2dip 
    [ swap ml-annotation boa ] dip  swap suffix 
    over name>>  "images/" prepend  swap ml-image boa
    swap image-copy ; 

: label-path ( label path -- )
    >folder-tree  dup entries>>  swapd
    [ name>> file-extension dup "jpg" =  swap "jpeg" =  or ] filter
    [ over label-box ] map  nip
    ANNOTATIONS get  swap append  ANNOTATIONS set
    drop
    ;

TUPLE: ImageFolder  name label ;

: combine-images ( path -- )
    >folder dup IMAGE-FOLDER set
    { } ANNOTATIONS set
    entries>> not-hidden
    [ dup name>>  swap pathname>>  label-path ] each
    ANNOTATIONS get
    ML-FOLDER get "/annotations.json" append
    pprint-json>path
    ;
      
: do-us ( -- )
    "/Users/davec/Work/Training/Coins" dup COINS-FOLDER set
    dup "/AnnotatedML" append  ML-FOLDER set
    "/US" append combine-images ;

! Copyright (C) 2012 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel ;
IN: folder.compare

ARTICLE: "folder.compare" "folder.compare"
{ $vocab-link "folder.compare" }
;

ABOUT: "folder.compare"

HELP: <folder-compare>
{ $values { "src" "path to source folder" } { "dst" "path to destination folder" } { "folder.compare" "value" } }
{ $description "Creates an instance of a folder-compare object." }
;

HELP: folder-compare
{ $var-description "" } ;

HELP: folder-rm
{ $description "Using the intersection of two folders will remove files in the destination according to the mode." }

;
  
HELP: set-dir-word
{ $values { "folder.compare" "folder.compare" } { "t|f" boolean } { "folder.compare'" "folder.compare" } }
{ $description "Sets the property for deep or shallow inspection" }
;

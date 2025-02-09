USING: accessors help.markup help.syntax strings ;
IN: colors

HELP: nearest-color
{ $values { "hex|str" string } { "color" color } { "value" "hex" } }
{ $description "Finds the color that is >= the requested value and returns its "
  "name and value." }
{ $example
  "USING: colors prettyprint ;"
  "\"#097733\" nearest-color"
  "gray4"
  "657930"
}
;
  

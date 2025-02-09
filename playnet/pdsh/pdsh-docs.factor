! Copyright (C) 2014 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel sequences strings ;
IN: playnet.pdsh

ARTICLE: "playnet.pdsh" "PDSH"
{ $vocab-link "playnet.pdsh" }
$nl "This vocabulary defines some tools to help create and maintain a list of hosts for the http://sourceforge.net/projects/pdsh used to send commands to multiple servers in parallel"
;

ABOUT: "PDSH"

HELP: rename-duplicate {
    $description "Rename the record using the next hostNum value and append first two letters of the domain."
} ;

HELP: rename-duplicates {
    $description "From the list of records, pull out the playnet.com and wwiionline.com records and combine them and look for any duplicate host names in both domains" 
} ;

HELP: get-dns-records {
    $description "Collect and display the combined records"
} ;

HELP: append-new-hosts
{ $values
    { "lines" null }
    { "newhosts" null }
}
{ $description "Takes the current /etc/hosts file and splits it at the PLAYNET marker then appends the new host lines" } ;

HELP: bool>string
{ $values
    { "?" boolean }
    { "s" null }
}
{ $description "" } ;

HELP: do-system
{ $values
    { "string" string }
}
{ $description "" } ;

HELP: duplicate-hosts
{ $var-description "" } ;

HELP: fetch-dns-files
{ $description "" } ;

HELP: find-active-hosts
{ $values
    { "hosts" null }
}
{ $description "" } ;

HELP: gap-by-ip
{ $values
    { "lines" null }
}
{ $description "" } ;

HELP: gather-records
{ $values
    { "path" "a pathname string" }
    { "seq" sequence }
}
{ $description "" } ;

HELP: get-lines
{ $values
    { "s" null }
}
{ $description "" } ;

HELP: host-format
{ $values
    { "records" null }
    { "lines" null }
}
{ $description "" } ;

HELP: hostNum
{ $var-description "" } ;

HELP: hosts
{ $var-description "" } ;

HELP: hosts-to-prune
{ $values
    { "value" null }
}
{ $description "" } ;

HELP: make-records
{ $values
    { "lines" null }
    { "records" null }
}
{ $description "" } ;

HELP: new-hosts-lines
{ $values
    { "lines" null }
}
{ $description "" } ;

HELP: only-active
{ $values
    { "records" null }
}
{ $description "" } ;

HELP: ping-hosts
{ $values
    { "records" null }
}
{ $description "" } ;

HELP: playnet.com
{ $values
    { "records" null }
}
{ $description "" } ;

HELP: to-pn
{ $values
    { "records" null }
}
{ $description "" } ;

HELP: update-local-files
{ $description "" } ;

HELP: write-dsh-all
{ $description "" } ;

HELP: write-hosts-file
{ $description "" } ;

HELP: wwiionline.com
{ $values
    { "records" null }
}
{ $description "" } ;

HELP: create-new-hosts
{ $description "This is the primary creation word. It will fetch the two main DNS files from the name server, concatenate them together, then extract the A records and create a new hosts file an a new dsh file which will contain the active pingable hosts." }
;


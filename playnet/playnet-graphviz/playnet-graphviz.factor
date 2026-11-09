! Copyright (C) 2013 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries arrays combinators
graphviz io.encodings.utf8 io.files kernel namespaces regexp sequences 
graphviz.notation graphviz.render ;
IN: playnet-graphviz

<< "libgraph" "/opt/local/lib/libgraph.dylib" cdecl add-library >>

SYMBOL: collectedHosts 
SYMBOL: hostData 
SYMBOL: collectStage 

: collect-hosts ( path -- hosts ) 
    utf8 file-lines 
    { } collectedHosts set
    0 collectStage set
    [ 
        collectStage get {
            { 0 ! Look for first host
              [ dup  R/ Nmap scan report/ re-contains? 
                [ 1 collectStage set 
                  1array hostData set
                ] [ drop ] if
              ] 
            }
            { 1 ! Look for ports
              [ dup R/ open/ re-contains?
                [ 1array  hostData get  swap append
                  hostData set
                ] 
                ! Look for next host
                [ dup R/ Nmap scan report/ re-contains? 
                  [ collectedHosts get  hostData get  
                    1array append
                    collectedHosts set
                    1array hostData set
                  ] 
                  [ drop ] if
                ] if
              ]
            }
        } case
    ] each  
    collectedHosts get
;

: test ( -- hosts ) 
    "/Users/davec/Desktop/Log at 2013-12-12 14.45.23.txt" collect-hosts ;

: g1 ( -- graph )
<digraph>
    graph[ "LR" =rankdir "8,8" =size ];
    node[ 8 =fontsize "record" =shape ];

    "node0" add-node[
        "<f0> 0x10ba8| <f1>" =label
    ];
    "node1" add-node[
        "<f0> 0xf7fc4380| <f1> | <f2> |-1" =label
    ];
    "node2" add-node[
        "<f0> 0xf7fc44b8| | |2" =label
    ];
    "node3" add-node[
        "<f0> 3.43322790286038071e-06|44.79998779296875|0" =label
    ];
    "node4" add-node[
        "<f0> 0xf7fc4380| <f1> | <f2> |2" =label
    ];
    "node5" add-node[
        "<f0> (nil)| | |-1" =label
    ];
    "node6" add-node[
        "<f0> 0xf7fc4380| <f1> | <f2> |1" =label
    ];
    "node7" add-node[
        "<f0> 0xf7fc4380| <f1> | <f2> |2" =label
    ];
    "node8" add-node[
        "<f0> (nil)| | |-1" =label
    ];
    "node9" add-node[
        "<f0> (nil)| | |-1" =label
    ];
    "node10" add-node[
        "<f0> (nil)| <f1> | <f2> |-1" =label
    ];
    "node11" add-node[
        "<f0> (nil)| <f1> | <f2> |-1" =label
    ];
    "node12" add-node[
        "<f0> 0xf7fc43e0| | |1" =label
    ];

    "node0" "node1"   ->[ "f0" =tailport "f0" =headport ];
    "node0" "node2"   ->[ "f1" =tailport "f0" =headport ];
    "node1" "node3"   ->[ "f0" =tailport "f0" =headport ];
    "node1" "node4"   ->[ "f1" =tailport "f0" =headport ];
    "node1" "node5"   ->[ "f2" =tailport "f0" =headport ];
    "node4" "node3"   ->[ "f0" =tailport "f0" =headport ];
    "node4" "node6"   ->[ "f1" =tailport "f0" =headport ];
    "node4" "node10"  ->[ "f2" =tailport "f0" =headport ];
    "node6" "node3"   ->[ "f0" =tailport "f0" =headport ];
    "node6" "node7"   ->[ "f1" =tailport "f0" =headport ];
    "node6" "node9"   ->[ "f2" =tailport "f0" =headport ];
    "node7" "node3"   ->[ "f0" =tailport "f0" =headport ];
    "node7" "node1"   ->[ "f1" =tailport "f0" =headport ];
    "node7" "node8"   ->[ "f2" =tailport "f0" =headport ];
    "node10" "node11" ->[ "f1" =tailport "f0" =headport ];
    "node10" "node12" ->[ "f2" =tailport "f0" =headport ];
    "node11" "node1"  ->[ "f2" =tailport "f0" =headport ];
;

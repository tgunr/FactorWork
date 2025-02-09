! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: formatting io.encodings.utf8 io.files kernel libc math ;
IN: ham.halfwave

:: rw ( min_kHz max_kHz -- )
    1.8 :> loFreq_MHz
    468 2 *  loFreq_MHz / :> lambdaMax_ft ! Max wavelength in band
    468 loFreq_MHz /  2 /  :> qtr_ft
    min_kHz max_kHz loFreq_MHz
    "# %.3f to %.3f kHz, too short for %f MHz\n" printf
    0. 1e-3  qtr_ft  qtr_ft 1e-3 +
    "%.3f 0\n%.3f 1\n%.3f 1\n%.3f 0\n\n" printf
    1 :> n!  0 :> lambda0_ft  0 :> lambda1_ft
    ! Change '5' in next line to max number of multiples to calculate
    [ lambda1_ft lambdaMax_ft <  n 5 <  and ]
    [
        n 468 *  max_kHz 1e-3 *  /  :> lambda0_ft!
        n 468 *  min_kHz 1e-3 *  /  :> lambda1_ft!
        ! Print in format gnuplot expects.
        min_kHz max_kHz n
        "# %.3f to %.3f kHz, multiple %d\n" printf
        lambda0_ft 1e-3 -  lambda0_ft  lambda1_ft  lambda1_ft 1e-3 +
        "%.3f 0\n%.3f 1\n%.3f 1\n%.3f 0\n\n" printf
        n 1 + n!
    ] while
    ;



: half-waves ( -- )
    1800 2000 rw
    3500 4000 rw
    7000 7300 rw
    10100 10150 rw
    14000 14350 rw
    18068 18168 rw
    21000 21450 rw
    24890 24990 rw
    28000 29700 rw
    50000 54000 rw
    ;

: gnuplot-config ( -- string )
    "set xtics 5
    unset ytics
    set grid
    set xlabel 'Wire Length (feet)'
    set title 'Random Wire Lengths to Avoid'
    set term png size 1250,150
    set output 'f.png'
    plot [:][:1] 'f' with filledcurves notitle"
    ;

: save-half-waves ( -- )
    gnuplot-config "~/plot.config" utf8 set-file-contents
    "~/halfwaves" utf8 [ half-waves ] with-file-writer ;

: ref ( -- )
    "open https://udel.edu/~mm/ham/randomWire/" system drop ; 

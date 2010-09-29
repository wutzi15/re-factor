! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: ascii combinators fonts io kernel math math.parser
memoize sequences ;

IN: pdf.units

: inch ( n -- n' ) 72.0 * ;

: cm ( n -- n' ) inch 2.54 / ;

: mm ( n -- n' ) cm 0.1 * ;

: pica ( n -- n' ) 12.0 * ;

: string>points ( str -- n )
    dup [ digit? ] find-last drop 1 + cut
    [ string>number ] dip {
        { "cm"   [ cm ] }
        { "in"   [ inch ] }
        { "pt"   [ ] }
        { ""     [ ] }
        { "mm"   [ mm ] }
        { "pica" [ pica ] }
        [ throw ]
    } case ;


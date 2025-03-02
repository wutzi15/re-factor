! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: arrays assocs combinators db.types fry kernel lexer
macros math math.order parser sequences
sequences.generalizations ;
FROM: sequences => change-nth ;

IN: utils

MACRO: cleave-array ( quots -- )
    [ '[ _ cleave ] ] [ length '[ _ narray ] ] bi compose ;

: until-empty ( seq quot -- )
    [ dup empty? ] swap until drop ; inline

SYNTAX: =>
    unclip-last scan-object 2array suffix! ;

<PRIVATE

USE: accessors
USE: io.pathnames
USE: namespaces
USE: source-files
USE: vocabs.loader
USE: vocabs.parser

: (include) ( parsed name -- parsed )
    [ file get path>> parent-directory ] dip
    ".factor" append append-path parse-file append ;

PRIVATE>

SYNTAX: INCLUDE: scan-token (include) ;

SYNTAX: INCLUDING: ";" [ (include) ] each-token ;

: max-by ( obj1 obj2 quot: ( obj -- n ) -- obj1/obj2 )
    [ bi@ [ max ] keep eq? not ] curry most ; inline

: min-by ( obj1 obj2 quot: ( obj -- n ) -- obj1/obj2 )
    [ bi@ [ min ] keep eq? not ] curry most ; inline

: maximum ( seq quot: ( ... elt -- ... x ) -- elt )
    [ keep 2array ] curry
    [ [ first ] max-by ] map-reduce second ; inline

: minimum ( seq quot: ( ... elt -- ... x ) -- elt )
    [ keep 2array ] curry
    [ [ first ] min-by ] map-reduce second ; inline

: set-slots ( assoc obj -- )
    '[ swap _ set-slot-named ] assoc-each ;

: from-slots ( assoc class -- obj )
    new [ set-slots ] keep ;

: split1-when ( ... seq quot: ( ... elt -- ... ? ) -- ... before after )
    dupd find drop [ swap [ dup 1 + ] dip snip ] [ f ] if* ; inline

: group-by ( seq quot: ( elt -- key ) -- assoc )
    H{ } clone [
        [ push-at ] curry compose [ dup ] prepose each
    ] keep ; inline

: of ( assoc key -- value ) swap at ;

: deep-at ( assoc seq -- value/f )
    [ swap at ] each ;

USE: math.statistics
USE: sorting

: trim-histogram ( assoc n -- alist )
    [ sort-values reverse ] [ cut ] bi* values sum
    [ "Other" swap 2array suffix ] unless-zero ;

USE: locals
USE: math.ranges

:: each-subseq ( ... seq quot: ( ... x -- ... ) -- ... )
    seq length [0,b] [
        :> from
        from seq length (a,b] [
            :> to
            from to seq subseq quot call( x -- )
        ] each
    ] each ;

USE: quotations

MACRO: cond-case ( assoc -- )
    [
        dup callable? not [
            [ first [ dup ] prepose ]
            [ second [ drop ] prepose ] bi 2array
        ] when
    ] map [ cond ] curry ;

USE: assocs.private

: (assoc-merge) ( assoc1 assoc2 -- assoc1 )
    over [ push-at ] with-assoc assoc-each ;

: assoc-merge ( seq -- merge )
    H{ } clone [ (assoc-merge) ] reduce ;

USE: grouping

: all-subseqs ( seq -- seqs )
    dup length [1,b] [ <clumps> ] with map concat ;

:: longest-subseq ( seq1 seq2 -- subseq )
    seq1 length :> len1
    seq2 length :> len2
    0 :> n!
    0 :> end!
    len1 1 + [ len2 1 + 0 <array> ] replicate :> table
    len1 [1,b] [| x |
        len2 [1,b] [| y |
            x 1 - seq1 nth
            y 1 - seq2 nth = [
                y 1 - x 1 - table nth nth 1 + :> len
                len y x table nth set-nth
                len n > [ len n! x end! ] when
            ] [ 0 y x table nth set-nth ] if
        ] each
    ] each end n - end seq1 subseq ;

: swap-when ( x y quot: ( x -- n ) quot: ( n n -- ? ) -- x' y' )
    '[ _ _ 2dup _ bi@ @ [ swap ] when ] call ; inline

: change-nths ( ... indices seq quot: ( ... elt -- ... elt' ) -- ... )
    [ change-nth ] 2curry each ; inline

: majority ( seq -- elt/f )
    [ f 0 ] dip [
        over zero? [ 2nip 1 ] [
            pick = [ 1 + ] [ 1 - ] if
        ] if
    ] each zero? [ drop f ] when ;

: compose-all ( seq -- quot )
    [ ] [ compose ] reduce ;

USE: math.parser

: humanize ( n -- str )
    dup 100 mod 11 13 between? [ "th" ] [
        dup 10 mod {
            { 1 [ "st" ] }
            { 2 [ "nd" ] }
            { 3 [ "rd" ] }
            [ drop "th" ]
        } case
    ] if [ number>string ] [ append ] bi* ;

USE: alien.c-types
USE: classes.struct
USE: io

: read-struct ( class -- struct )
    [ heap-size read ] [ memory>struct ] bi ;

USE: random

: remove-random ( seq -- elt seq' )
    [ length random ] keep [ nth ] [ remove-nth ] 2bi ;

: rotate ( seq n -- seq' )
    cut prepend ;

USE: sets

: ?adjoin ( elt set -- elt/f )
    2dup in? [ 2drop f ] [ dupd adjoin ] if ;

: pad-longest ( seq1 seq2 elt -- seq1 seq2 )
    [ 2dup max-length ] dip [ pad-tail ] 2curry bi@ ;

USE: parser
USE: generic
USE: tools.annotations

<<
: wrap-method ( word before-quot after-quot -- )
    pick reset [ surround ] 2curry annotate ;
>>

<<
SYNTAX: BEFORE:
    scan-word scan-word lookup-method
    parse-definition [ ] wrap-method ;

SYNTAX: AFTER:
    scan-word scan-word lookup-method
    [ ] parse-definition wrap-method ;
>>

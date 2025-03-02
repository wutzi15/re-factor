! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs help help.markup help.topics
io.encodings.utf8 io.files io.pathnames kernel pdf.layout
pdf.streams sequences sets strings ;

IN: help.pdf

<PRIVATE

: next-articles ( str -- seq )
    article content>> [ array? ] filter
    [ first \ $subsections eq? ] filter
    [ rest [ string? ] filter ] map concat members ;

: topic>pdf ( str -- pdf )
    [
        [ print-topic ]
        [
            next-articles [
                [ article-title $heading ]
                [ article-content print-content ] bi
            ] each
        ] bi
    ] with-pdf-writer ;

: topics>pdf ( seq -- pdf )
    [ topic>pdf ] map <pb> 1array join ;

: write-pdf ( pdf name -- )
    [ pdf>string ] dip home prepend-path utf8 set-file-contents ;

PRIVATE>

: article-pdf ( str name -- )
    [
        [ [ print-topic ] with-pdf-writer ]
        [ next-articles topics>pdf ] bi
        [ <pb> 1array glue ] unless-empty
    ] [ write-pdf ] bi* ;

: cookbook-pdf ( -- )
    "cookbook" "cookbook.pdf" article-pdf ;

: first-program-pdf ( -- )
    "first-program" "first-program.pdf" article-pdf ;

: handbook-pdf ( -- )
    "handbook-language-reference" "handbook.pdf" article-pdf ;

: system-pdf ( -- )
    "handbook-system-reference" "system.pdf" article-pdf ;

: tools-pdf ( -- )
    "handbook-tools-reference" "tools" article-pdf ;

: index-pdf ( -- )
    {
        "vocab-index"
        "article-index"
        "primitive-index"
        "error-index"
        "class-index"
    } topics>pdf "index.pdf" write-pdf ;



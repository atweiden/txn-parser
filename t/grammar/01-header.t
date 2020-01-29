use v6;
use lib 'lib';
use TXN::Parser::Grammar;
use lib 't/lib';
use TXNParserTest;
use Test;

plan(4);

# date grammar tests {{{

subtest({
    my Str @date =
        Q{2014-01-01},
        Q{2014-01-01T08:48:00Z},
        Q{2014-01-01T08:48:00},
        Q{2014-01-01T08:48:00-07:00},
        Q{2014-01-01T08:48:00},
        Q{2014-01-01T08:48:00.99999-07:00},
        Q{2014-01-01T08:48:00.99999},
        Q{2014-01-01 08:48:00Z};

    ok(
        @date.grep({ .&is-valid-date }).elems == @date.elems,
        q:to/EOF/
        ♪ [Grammar.parse($date, :rule<date>)] - 1 of 8
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Dates validate successfully, as expected.
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
});

# end date grammar tests }}}
# metainfo grammar tests {{{

subtest({
    my Str @metainfo =
        Q{#tag1 ! #TAG2 !! #TAG5 #bliss !!!!!},
        Q{#"∅" !! #96 !!!!};

    my Str $metainfo-multiline = Q:to/EOF/.trim;
    !!!-- comment
    #tag1 -- comment
    -- comment
    #tag2 -- comment
    -- another comment
    #tag3--comment
    !!!!!
    EOF

    push(@metainfo, $metainfo-multiline);

    ok(
        @metainfo.grep({ .&is-valid-metainfo }).elems == @metainfo.elems,
        q:to/EOF/
        ♪ [Grammar.parse($metainfo, :rule<metainfo>)] - 2 of 8
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Metainfo validates successfully, as expected.
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
});

# end metainfo grammar tests }}}
# description grammar tests {{{

subtest({
    my Str @description =
        Q{"Transaction\tDescription"},
        Q{"""Transaction\nDescription"""},
        Q{'Transaction Description\'};
        Q{'''Transaction Description\'''};

    my Str $description-multiline = Q:to/EOF/.trim;
    """
    Multiline description line one. \
    Multiline description line two.
    """
    EOF

    push(@description, $description-multiline);

    ok(
        @description
            .grep({ .&is-valid-description })
            .elems == @description.elems,
        q:to/EOF/
        ♪ [Grammar.parse($description, :rule<description>)] - 3 of 8
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Descriptions validates successfully, as expected.
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
});

# end description grammar tests }}}
# header grammar tests {{{

subtest({
    my Str @header =
        qq{2014-01-01 "I started with 1000 USD" ! #TAG1 #TAG2 -- COMMENT\n},
        qq{2014-01-02 "I paid Exxon Mobile 10 USD"\n},
        qq{2014-01-02\n},
        qq{2014-01-03 "I bought ฿0.80000000 BTC for 800 USD#@*!%"\n};

    my Str $header-multiline = Q:to/EOF/;
    2014-05-09-- comment
    -- comment
    #tag1 #tag2 #tag3 !!!-- comment
    -- comment
    """ -- non-comment
    This is a multiline description of the transaction.
    This is another line of the multiline description.
    """-- comment
    --comment
    #tag4--comment
    --comment
    #tag5--comment
    #tag6--comment
    --comment
    !!!-- comment here
    EOF

    push(@header, $header-multiline);

    is(
        TXN::Parser::Grammar.parse(@header[0], :rule<header>).WHAT,
        TXN::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($header, :rule<header>)] - 4 of 8
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Header validates successfully, as expected.
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        TXN::Parser::Grammar.parse(@header[1], :rule<header>).WHAT,
        TXN::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($header, :rule<header>)] - 5 of 8
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Header validates successfully, as expected.
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        TXN::Parser::Grammar.parse(@header[2], :rule<header>).WHAT,
        TXN::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($header, :rule<header>)] - 6 of 8
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Header validates successfully, as expected.
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        TXN::Parser::Grammar.parse(@header[3], :rule<header>).WHAT,
        TXN::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($header, :rule<header>)] - 7 of 8
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Header validates successfully, as expected.
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        TXN::Parser::Grammar.parse(@header[4], :rule<header>).WHAT,
        TXN::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($header, :rule<header>)] - 8 of 8
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Multiline header validates successfully, as
        ┃   Success   ┃    expected.
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    )
});

# end header grammar tests }}}

# vim: set filetype=raku foldmethod=marker foldlevel=0:

use v6;
use lib 'lib';
use lib 't/lib';
use Test;
use TestTXNParser;
use TXN::Parser;

plan 3;

subtest
{
    my Str $file = 't/data/sample/sample.txn';
    my TXN::Parser::Actions $actions .= new;
    my $match-journal = TXN::Parser::Grammar.parsefile($file, :$actions);

    is(
        $match-journal.WHAT,
        Match,
        q:to/EOF/
        ♪ [Grammar.parse($document)] - 1 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses transaction journal successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-journal.made.WHAT,
        Array,
        q:to/EOF/
        ♪ [Is array?] - 2 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-journal.made.WHAT ~~ Array
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    is(
        $match-journal.made[0]<header><date>.Date,
        "2014-01-01",
        q:to/EOF/
        ♪ [Is expected value?] - 3 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-journal.made[0]<header><date>.Date
        ┃   Success   ┃        ~~ "2014-01-01"
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-journal.made[0]<header><description>,
        'I started the year with $1000 in Bankwest cheque account',
        q:to/EOF/
        ♪ [Is expected value?] - 4 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-journal.made[0]<header><description>
        ┃   Success   ┃        ~~ '...'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-journal.made[0]<header><important>,
        0,
        q:to/EOF/
        ♪ [Is expected value?] - 5 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-journal.made[0]<header><important>
        ┃   Success   ┃        == 0
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-journal.made[0]<header><tags>[0],
        'TAG1',
        q:to/EOF/
        ♪ [Is expected value?] - 6 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-journal.made[0]<header><tags>[0]
        ┃   Success   ┃        ~~ 'TAG1'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-journal.made[0]<header><tags>[1],
        'TAG2',
        q:to/EOF/
        ♪ [Is expected value?] - 7 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-journal.made[0]<header><tags>[1]
        ┃   Success   ┃        ~~ 'TAG2'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-journal.made[0]<id><number>,
        0,
        q:to/EOF/
        ♪ [Is expected value?] - 8 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-journal.made[0]<id><number>
        ┃   Success   ┃        == 0
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-journal.made[0]<id><text>,
        "2014-01-01 \"I started the year with \$1000 in Bankwest cheque account\" \@TAG1 \@TAG2 # EODESC COMMENT\n  # this is a comment line\n  Assets:Personal:Bankwest:Cheque    \$1000.00 USD\n  # this is a second comment line\n  Equity:Personal                    \$1000.00 USD # EOL COMMENT\n  # this is a third comment line\n# this is a stray comment\n# another\n",
        q:to/EOF/
        ♪ [Is expected value?] - 9 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-journal.made[0]<id><text>
        ┃   Success   ┃        ~~ "..."
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-journal.made[0]<id><xxhash>,
        3251202721,
        q:to/EOF/
        ♪ [Is expected value?] - 10 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-journal.made[0]<id><xxhash>
        ┃   Success   ┃        == 3251202721
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-journal.made[0]<postings>[0]<account><entity>,
        'Personal',
        q:to/EOF/
        ♪ [Is expected value?] - 11 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-journal.made[0]<postings>[0]<account><entity>
        ┃   Success   ┃        ~~ 'Personal'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-journal.made[0]<postings>[0]<account><silo>,
        'ASSETS',
        q:to/EOF/
        ♪ [Is expected value?] - 12 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-journal.made[0]<postings>[0]<account><silo>
        ┃   Success   ┃        ~~ 'ASSETS'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-journal.made[0]<postings>[0]<account><subaccount>[0],
        'Bankwest',
        q:to/EOF/
        ♪ [Is expected value?] - 13 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-journal.made[0]<postings>[0]<account><subaccount>[0]
        ┃   Success   ┃        ~~ 'Bankwest'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-journal.made[0]<postings>[0]<account><subaccount>[1],
        'Cheque',
        q:to/EOF/
        ♪ [Is expected value?] - 14 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-journal.made[0]<postings>[0]<account><subaccount>[1]
        ┃   Success   ┃        ~~ 'Cheque'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-journal.made[0]<postings>[0]<amount><asset-code>,
        'USD',
        q:to/EOF/
        ♪ [Is expected value?] - 15 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-journal.made[0]<postings>[0]<amount><asset-code>
        ┃   Success   ┃        ~~ 'USD'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-journal.made[0]<postings>[0]<amount><asset-quantity>,
        1000.0,
        q:to/EOF/
        ♪ [Is expected value?] - 16 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-journal.made[0]<postings>[0]<amount><asset-quantity>
        ┃   Success   ┃        == 1000.0
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-journal.made[0]<postings>[0]<amount><asset-symbol>,
        '$',
        q:to/EOF/
        ♪ [Is expected value?] - 17 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-journal.made[0]<postings>[0]<amount><asset-symbol>
        ┃   Success   ┃        ~~ '$'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-journal.made[0]<postings>[0]<amount><exchange-rate>,
        {},
        q:to/EOF/
        ♪ [Is expected value?] - 18 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-journal.made[0]<postings>[0]<amount><exchange-rate>
        ┃   Success   ┃        ~~ {}
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-journal.made[0]<postings>[0]<amount><plus-or-minus>,
        '',
        q:to/EOF/
        ♪ [Is expected value?] - 19 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-journal.made[0]<postings>[0]<amount><plus-or-minus>
        ┃   Success   ┃        ~~ ''
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-journal.made[0]<postings>[0]<decinc>,
        'INC',
        q:to/EOF/
        ♪ [Is expected value?] - 20 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-journal.made[0]<postings>[0]<decinc>
        ┃   Success   ┃        ~~ 'INC'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-journal.made[0]<postings>[0]<id><number>,
        0,
        q:to/EOF/
        ♪ [Is expected value?] - 21 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-journal.made[0]<postings>[0]<id><number>
        ┃   Success   ┃        == 0
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-journal.made[0]<postings>[0]<id><text>,
        'Assets:Personal:Bankwest:Cheque    $1000.00 USD',
        q:to/EOF/
        ♪ [Is expected value?] - 22 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-journal.made[0]<postings>[0]<id><text>
        ┃   Success   ┃        ~~ '...'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-journal.made[0]<postings>[0]<id><xxhash>,
        352942826,
        q:to/EOF/
        ♪ [Is expected value?] - 23 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-journal.made[0]<postings>[0]<id><xxhash>
        ┃   Success   ┃        == 352942826
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-journal.made[0]<postings>[0]<id><entry-id><number>,
        0,
        q:to/EOF/
        ♪ [Is expected value?] - 24 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-journal.made[0]<postings>[0]<id><entry-id><number>
        ┃   Success   ┃        == 0
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-journal.made[0]<postings>[0]<id><entry-id><text>,
        "2014-01-01 \"I started the year with \$1000 in Bankwest cheque account\" \@TAG1 \@TAG2 # EODESC COMMENT\n  # this is a comment line\n  Assets:Personal:Bankwest:Cheque    \$1000.00 USD\n  # this is a second comment line\n  Equity:Personal                    \$1000.00 USD # EOL COMMENT\n  # this is a third comment line\n# this is a stray comment\n# another\n",
        q:to/EOF/
        ♪ [Is expected value?] - 25 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-journal.made[0]<postings>[0]<id><entry-id><text>
        ┃   Success   ┃        ~~ "..."
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-journal.made[0]<postings>[0]<id><entry-id><xxhash>,
        3251202721,
        q:to/EOF/
        ♪ [Is expected value?] - 26 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-journal.made[0]<postings>[0]<id><entry-id><xxhash>
        ┃   Success   ┃        == 3251202721
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

subtest
{
    my Str $file = 't/data/with-includes/with-includes.txn';
    my @txn = TXN::Parser.parsefile($file).made;

    is-deeply(
        @txn,
        @TestTXNParser::with-includes,
        q:to/EOF/
        ♪ [Is expected value?] - 27 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ @txn eqv @TestTXNParser::with-includes
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# verify existence of primary and secondary exchange rate
subtest
{
    my Str $txn = q:to/EOF/;
    2016-04-26 '''
    I receive a gift of 5 BTC

    - market price is $466/BTC
    - donor's basis was $0.04/BTC
    '''
    Assets:Personal:ColdStorage    ฿5 BTC @ $466 USD ==> $0.04 USD
    Income:Personal:Gifts          ฿5 BTC @ $466 USD
    EOF

    my @txn = TXN::Parser.parse($txn).made;

    is(
        @txn[0]<postings>[0]<amount><asset-code>,
        "BTC",
        q:to/EOF/
        ♪ [Is expected value?] - 28 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ @txn[0]<postings>[0]<amount><asset-code> eq 'BTC'
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        @txn[0]<postings>[0]<amount><asset-quantity>,
        5,
        q:to/EOF/
        ♪ [Is expected value?] - 29 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ @txn[0]<postings>[0]<amount><asset-quantity> == 5
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        @txn[0]<postings>[0]<amount><asset-symbol>,
        "฿",
        q:to/EOF/
        ♪ [Is expected value?] - 30 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ @txn[0]<postings>[0]<amount><asset-symbol> eq '฿'
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        @txn[0]<postings>[0]<amount><exchange-rate><asset-code>,
        "USD",
        q:to/EOF/
        ♪ [Is expected value?] - 31 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ @txn[0]<postings>[0]<amount><exchange-rate><asset-code>
        ┃   Success   ┃         eq 'USD'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        @txn[0]<postings>[0]<amount><exchange-rate><asset-quantity>,
        466,
        q:to/EOF/
        ♪ [Is expected value?] - 32 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ @txn[0]<postings>[0]<amount><exchange-rate><asset-quantity>
        ┃   Success   ┃         == 466
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        @txn[0]<postings>[0]<amount><exchange-rate><asset-symbol>,
        '$',
        q:to/EOF/
        ♪ [Is expected value?] - 33 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ @txn[0]<postings>[0]<amount><exchange-rate><asset-symbol>
        ┃   Success   ┃         eq '$'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        @txn[0]<postings>[0]<amount><exchange-rate><xe-secondary><asset-code>,
        "USD",
        q:to/EOF/
        ♪ [Is expected value?] - 34 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ @txn[0]<postings>[0]<amount><exchange-rate><xe-secondary><asset-code>
        ┃   Success   ┃         eq 'USD'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        @txn[0]<postings>[0]<amount><exchange-rate><xe-secondary><asset-quantity>,
        0.04,
        q:to/EOF/
        ♪ [Is expected value?] - 35 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ @txn[0]<postings>[0]<amount><exchange-rate><xe-secondary><asset-quantity>
        ┃   Success   ┃         == 0.04
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        @txn[0]<postings>[0]<amount><exchange-rate><xe-secondary><asset-symbol>,
        '$',
        q:to/EOF/
        ♪ [Is expected value?] - 36 of 36
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ @txn[0]<postings>[0]<amount><exchange-rate><xe-secondary><asset-symbol>
        ┃   Success   ┃         eq '$'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# vim: ft=perl6 fdm=marker fdl=0 nowrap

use v6;
use X::TXN::Parser;
unit grammar TXN::Parser::Grammar;

# track silo
my enum Silo <ASSETS EXPENSES INCOME LIABILITIES EQUITY>;
my Silo $silo;

# disposable grammar {{{

proto token gap {*}
token gap:spacer { \s }
token gap:comment { <.comment> $$ }

# end disposable grammar }}}
# comment grammar {{{

token comment
{
    '--' <comment-text>
}

token comment-text
{
    \N*
}

# end comment grammar }}}
# string grammar {{{

proto token string {*}
token string:basic { <string-basic> }
token string:basic-multi { <string-basic-multiline> }
token string:literal { <string-literal> }
token string:literal-multi { <string-literal-multiline> }

# --- string basic grammar {{{

token string-basic
{
    '"' <string-basic-text>? '"'
}

token string-basic-text
{
    <string-basic-char>+
}

proto token string-basic-char {*}

# anything but linebreaks, double-quotes, backslashes and control
# characters (U+0000 to U+001F, U+007F)
token string-basic-char:common
{
    <+[\N] -[\" \\] -[\x00..\x1F] -[\x7F]>
}

token string-basic-char:tab
{
    \t
}

# backslash followed by a valid (TOML) escape code, or error
token string-basic-char:escape-sequence
{
    \\
    [
        <escape>

        ||

        .
        { die(X::TXN::Parser::String::EscapeSequence.new(:esc(~$/))) }
    ]
}

# For convenience, some popular characters have a compact escape sequence.
#
# \b         - backspace       (U+0008)
# \t         - tab             (U+0009)
# \n         - linefeed        (U+000A)
# \f         - form feed       (U+000C)
# \r         - carriage return (U+000D)
# \"         - quote           (U+0022)
# \\         - backslash       (U+005C)
# \uXXXX     - unicode         (U+XXXX)
# \UXXXXXXXX - unicode         (U+XXXXXXXX)
proto token escape {*}
token escape:sym<b> { <sym> }
token escape:sym<t> { <sym> }
token escape:sym<n> { <sym> }
token escape:sym<f> { <sym> }
token escape:sym<r> { <sym> }
token escape:sym<quote> { \" }
token escape:sym<backslash> { \\ }
token escape:sym<u> { <sym> <hex> ** 4 }
token escape:sym<U> { <sym> <hex> ** 8 }

# Hex values are case insensitive.
token hex
{
    :i <[0..9A..F]>
}

token string-basic-multiline
{
    <string-basic-multiline-delimiter>
    <string-basic-multiline-leading-newline>?
    <string-basic-multiline-text>?
    <string-basic-multiline-delimiter>
}

token string-basic-multiline-delimiter
{
    '"""'
}

# A newline immediately following the opening delimiter will be trimmed.
token string-basic-multiline-leading-newline
{
    \n
}

token string-basic-multiline-text
{
    <string-basic-multiline-char>+
}

proto token string-basic-multiline-char {*}

# anything but delimiters ("""), backslashes and control characters
# (U+0000 to U+001F, U+007F)
token string-basic-multiline-char:common
{
    <-string-basic-multiline-delimiter -[\\] -[\x00..\x1F] -[\x7F]>
}

token string-basic-multiline-char:tab
{
    \t
}

token string-basic-multiline-char:newline
{
    \n+
}

# backslash followed by either a valid (TOML) escape code or linebreak
# with optional leading horizontal whitespace, else error
token string-basic-multiline-char:escape-sequence
{
    \\
    [
        [
            | <escape>
            | \h* $$ <ws-remover>
        ]

        ||

        .
        { die(X::TXN::Parser::String::EscapeSequence.new(:esc(~$/))) }
    ]
}

# For writing long strings without introducing extraneous whitespace,
# end a line with a \. The \ will be trimmed along with all whitespace
# (including newlines) up to the next non-whitespace character or
# closing delimiter.
token ws-remover
{
    \n+\s*
}

# --- end string basic grammar }}}
# --- string literal grammar {{{

token string-literal
{
    \' <string-literal-text>? \'
}

token string-literal-text
{
    <string-literal-char>+
}

proto token string-literal-char {*}

# anything but linebreaks and single quotes
# Since there is no escaping, there is no way to write a single quote
# inside a literal string enclosed by single quotes.
token string-literal-char:common
{
    <+[\N] -[\']>
}

token string-literal-char:backslash
{
    \\
}

token string-literal-multiline
{
    <string-literal-multiline-delimiter>
    <string-literal-multiline-leading-newline>?
    <string-literal-multiline-text>?
    <string-literal-multiline-delimiter>
}

token string-literal-multiline-delimiter
{
    \'\'\'
}

# A newline immediately following the opening delimiter will be trimmed.
token string-literal-multiline-leading-newline
{
    \n
}

token string-literal-multiline-text
{
    <string-literal-multiline-char>+
}

proto token string-literal-multiline-char {*}

# anything but delimiters (''') and backslashes
token string-literal-multiline-char:common
{
    <-string-literal-multiline-delimiter -[\\]>
}

token string-literal-multiline-char:backslash
{
    \\
}

# --- end string literal grammar }}}
# --- var-name string grammar {{{

# quoted variable names can be either basic strings or literal strings
proto token var-name-string {*}
token var-name-string:basic { '"' <string-basic-text> '"' }
token var-name-string:literal { \' <string-literal-text> \' }

# --- end var-name string grammar }}}
# --- txnlib string grammar {{{

token txnlib-string
{
    <txnlib-string-delimiter-left>
    <txnlib-string-text>
    <txnlib-string-delimiter-right>
}

token txnlib-string-delimiter-left
{
    '<'
}

token txnlib-string-delimiter-right
{
    '>'
}

token txnlib-string-path-divisor
{
    '/'
}

token txnlib-string-text
{
    <txnlib-string-char>+
}

proto token txnlib-string-char {*}

# anything but newlines, horizontal whitespace, path divisor,
# right-delimiter or backslash
token txnlib-string-char:common
{
    <+[\N]
     -[\h]
     -txnlib-string-path-divisor
     -txnlib-string-delimiter-right
     -[\\]>
}

proto token txnlib-escape {*}
token txnlib-escape:sym<backslash> { \\ }
token txnlib-escape:sym<delimiter-right> { <txnlib-string-delimiter-right> }
token txnlib-escape:sym<horizontal-ws> { \h }
token txnlib-escape:sym<path-divisor> { <txnlib-string-path-divisor> }

# backslash followed by a valid escape code else error
token txnlib-string-char:escape-sequence
{
    \\
    [
        <txnlib-escape>

        ||

        .
        { die(X::TXN::Parser::String::EscapeSequence.new(:esc(~$/))) }
    ]
}

token txnlib-string-char:path-divisor
{
    <txnlib-string-path-divisor>
}

# --- end txnlib string grammar }}}

# end string grammar }}}
# number grammar {{{

proto token plus-or-minus {*}
token plus-or-minus:sym<+> { <sym> }
token plus-or-minus:sym<-> { <sym> }

token integer
{
    <plus-or-minus>? <integer-unsigned>
}

token integer-unsigned
{
    <whole-number>
}

# Leading zeros are not allowed.
token whole-number
{
    | 0
    | <[1..9]> [ '_'? <.digits> ]?
}

# For large numbers, you may use underscores to enhance readability. Each
# underscore must be surrounded by at least one digit.
token digits
{
    | \d+
    | \d+ '_' <.digits>
}

token float
{
    <plus-or-minus>? <float-unsigned>
}

token float-unsigned
{
    <integer-part=.integer-unsigned> '.' <fractional-part=.digits>
}

# end number grammar }}}
# datetime grammar {{{

proto token date {*}

# RFC 3339 timestamp: http://tools.ietf.org/html/rfc3339
token date:date-time
{
    <date-time>
}

# RFC 3339 timestamp (omit local offset)
token date:date-time-omit-local-offset
{
    <date-time-omit-local-offset>
}

# YYYY-MM-DD
token date:full-date
{
    <full-date>
}

token date-fullyear
{
    \d ** 4
}

token date-month
{
    | 0 <[1..9]>
    | 1 <[0..2]>
}

token date-mday
{
    | 0 <[1..9]>
    | <[1..2]> \d
    | 3 <[0..1]>
}

token time-hour
{
    | <[0..1]> \d
    | 2 <[0..3]>
}

token time-minute
{
    <[0..5]> \d
}

# The grammar element time-second may have the value "60" at the end of
# months in which a leap second occurs.
token time-second
{
    | <[0..5]> \d
    | 60
}

token time-secfrac
{
    '.' \d+
}

token time-numoffset
{
    <plus-or-minus> <time-hour> ':' <time-minute>
}

token time-offset
{
    | <[Zz]>
    | <time-numoffset>
}

token partial-time
{
    <time-hour> ':' <time-minute> ':' <time-second> <time-secfrac>?
}

token full-date
{
    <date-fullyear> '-' <date-month> '-' <date-mday>
}

token full-time
{
    <partial-time> <time-offset>
}

token date-time
{
    <full-date> <[Tt\h]> <full-time>
}

token date-time-omit-local-offset
{
    <full-date> <[Tt\h]> <partial-time>
}

# end datetime grammar }}}
# variable name grammar {{{

proto token var-name {*}
token var-name:bare { <var-name-bare> }
token var-name:quoted { <var-name-string> }

# bare varnames are not allowed to start with a hyphen
token var-name-bare
{
    <alnum>
    <+alnum +[-]>*
}

# end variable grammar }}}
# entry grammar {{{

regex entry
{
    <header>
    <postings>
}

# --- header grammar {{{

regex header
{
    ^^ \h* <date> [ <.gap>+ <metainfo> ]?
    [ <.gap>+ <description> [ <.gap>+ <metainfo> ]? ]?
    <.gap>*
}

token description
{
    <string>
}

token metainfo
{
    <meta> [ <.gap>+ <meta> ]*
}

proto token meta {*}
token meta:important { <important> }
token meta:tag { <tag> }

token important
{
    <exclamation-mark>+
}

token exclamation-mark
{
    '!'
}

token tag
{
    '#' <var-name>
}

# --- end header grammar }}}
# --- posting grammar {{{

token postings
{
    [ \n [<.comment-line> \n]* <posting-line> ]+
}

token posting-line
{
    ^^ \h* <posting> \h* <.comment>? $$
}

token posting
{
    <account> \h+ <amount> [ \h+ <annot> ]?
}

# --- --- posting account grammar {{{

# silo and entity are required, path is optional
token account
{
    <silo> <account-delimiter> <entity=.var-name>
    [ <account-delimiter> <account-path=.account-name> ]?
}

proto token silo {*}

token silo:assets
{
    :i asset[s]?
    { $silo = ASSETS }
}

token silo:expenses
{
    :i expense[s]?
    { $silo = EXPENSES }
}

token silo:income
{
    :i
    | income
    | revenue[s]?
    { $silo = INCOME }
}

token silo:liabilities
{
    :i liabilit[y|ies]
    { $silo = LIABILITIES }
}

token silo:equity
{
    :i equit[y|ies]
    { $silo = EQUITY }
}

# accounts can be separated by a colon (:) or period (.)
proto token account-delimiter {*}
token account-delimiter:sym<:> { <sym> }
token account-delimiter:sym<.> { <sym> }

token account-name
{
    <var-name> [ <account-delimiter> <var-name> ]*
}

# --- --- end posting account grammar }}}
# --- --- posting amount grammar {{{

proto token amount {*}

token amount:commodity
{
    # -42 oz·Au
    | [
        <plus-or-minus>? <asset-quantity> \h+
            <unit-of-measure> \h* <of> \h* <asset-code>
    ]
    # -42 oz of Au
    | [
        <plus-or-minus>? <asset-quantity> \h+
            <unit-of-measure> \h+ of \h+ <asset-code>
    ]
}

token amount:asset
{
    # -$100.00 USD
    | <plus-or-minus>? <asset-symbol>? <asset-quantity> \h+ <asset-code>
    # USD -$100.00
    | <asset-code> \h+ <plus-or-minus>? <asset-symbol>? <asset-quantity>
}

proto token asset-code {*}
token asset-code:bare { <:Letter>+ }
token asset-code:quoted { <var-name-string> }

# any char excluding digits, plus signs, whitespace or unicode punctuation
# less periods and slashes (some currencies use these)
#
# unicode punctuation is any character from the Unicode General Category
# "Punctuation": https://www.fileformat.info/info/unicode/category/index.htm
#
# e.g. http://www.xe.com/symbols.php
token asset-symbol
{
    <+[\D] -[+] -[\s] -punct +[./]>+
}

proto token asset-quantity {*}

token asset-quantity:float
{
    <float-unsigned>
    { +$/ !== 0 or die(X::TXN::Parser::AssetQuantityIsZero.new(:text(~$/))) }
}

token asset-quantity:integer
{
    <integer-unsigned>
    { +$/ !== 0 or die(X::TXN::Parser::AssetQuantityIsZero.new(:text(~$/))) }
}

token unit-of-measure
{
    # --- --- --- digital units of measure {{{

    # see: https://physics.nist.gov/cuu/Units/binary.html

    #                      | bits      | bytes
                           | b  | bit  | B
    # kibibytes | kibibits | kilobits  | kilobytes
    | KiB       | Kib      | kb | kbit | kB
    # mebibytes | mebibits | megabits  | megabytes
    | MiB       | Mib      | Mb | Mbit | MB
    # gibibytes | gibibits | gigabits  | gigabytes
    | GiB       | Gib      | Gb | Gbit | GB
    # tebibytes | tebibits | terabits  | terabytes
    | TiB       | Tib      | Tb | Tbit | TB
    # pebibytes | pebibits | petabits  | petabytes
    | PiB       | Pib      | Pb | Pbit | PB
    # exbibytes | exbibits | exabits   | exabytes
    | EiB       | Eib      | Eb | Ebit | EB
    # zebibytes | zebibits | zettabits | zettabytes
    | ZiB       | Zib      | Zb | Zbit | ZB
    # yobibytes | yobibits | yottabits | yottabytes
    | YiB       | Yib      | Yb | Ybit | YB

    # --- --- --- end digital units of measure }}}
    # --- --- --- physical units of measure {{{

    # meters | nanometers | millimeters | centimeters | decimeters | kilometers
    | 'm'    | 'nm'       | 'mm'        | 'cm'        | 'dc'       | 'km'
    # square "
    | 'm²'   | 'nm²'      | 'mm²'       | 'cm²'       | 'dc²'      | 'km²'
    # cubic "
    | 'm³'   | 'nm³'      | 'mm³'       | 'cm³'       | 'dc³'      | 'km³'
    # inches | feet  | yards | miles | nautical miles
    | 'in'   | 'ft'  | 'yd'  | 'mi'  | 'sm'
    # square "
    | 'in²'  | 'ft²' | 'yd²' | 'mi²' | 'sm²'
    # cubic "
    | 'in³'  | 'ft³' | 'yd³' | 'mi³' | 'sm³'
    # acres  | ares  | hectares
    | 'acre' | 'are' | 'ha' | 'hectare'
    # liters | nanoliters | milliliters | centiliters | deciliters | kiloliters
    | 'l'    | 'nl'       | 'ml'        | 'cl'        | 'dl'       | 'kl'
    | 'L'    | 'nL'       | 'mL'        | 'cL'        | 'dL'       | 'kL'
    # teaspoons
    | 'tsp' | 'tspn'
    # tablespoons
    | 'tbsp' | 'tbspn'
    # cups
    | 'c' | 'cup'
    # pints
    | 'pt' | 'pint'
    # quarts
    | 'qt'
    # gallons
    | 'gal'
    # US gallons
    | 'usgal' | 'USgal'
    # imperial gallons
    | 'impgal'
    # fluid ounces
    | 'floz' | 'ozfl'
    # grams | nanograms | milligrams | centigrams | decigrams | kilograms
    | 'g'   | 'ng'      | 'mg'       | 'cg'       | 'dg'      | 'kg'
    # grains
    | 'gr'
    # pennyweights
    | 'dwt'
    # ounces
    | 'oz'
    # troy ounces
    | 'toz' | 'ozt'
    # carats
    | 'ct'
    # pounds
    | 'lb' | 'lbs'
    # tons  | tonnes (metric tons)
    | 'ton' | 't'
    # cubic "
    | 'ton³' | 't³'
    # twenty-foot equivalent unit
    | 'teu' | 'TEU'
    # cords
    | 'cord'
    # brass
    | 'brass'

    # --- --- --- end physical units of measure }}}
}

token of
{
    # bullet operator (u+2219)
    | '∙'
    # dot operator (u+22c5)
    | '⋅'
    # greek ano teleia (u+0387)
    | '·'
    # hyphenation point (u+2027)
    | '‧'
    # middle dot (u+00b7)
    | '·'
}

# --- --- end posting amount grammar }}}
# --- --- posting annotation grammar {{{

token annot
{
    # xe,inherit,lot
    [
        | <xe> \h+ <inherit> \h+ <lot>
        | <xe> \h+ <lot> \h+ <inherit>
        | <lot> \h+ <xe> \h+ <inherit>
    ]

    |

    # xe,inherit
    [
        | <xe> \h+ <inherit>
    ]

    |

    # xe,lot
    [
        | <xe> \h+ <lot>
        | <lot> \h+ <xe>
    ]

    |

    # inherit,lot
    [
        | <inherit> \h+ <lot>
        | <lot> \h+ <inherit>
    ]

    |

    # xe
    [
        | <xe>
    ]

    |

    # inherit
    [
        | <inherit>
    ]

    |

    # lot
    [
        | <lot>
    ]
}

# --- --- --- xe {{{

# exchange rate
token xe
{
    <xe-symbol> \h+ <xe-rate>
}

proto token xe-symbol {*}
token xe-symbol:per-unit { <xe-symbol-char> }
token xe-symbol:in-total { <xe-symbol-char> ** 2 }

token xe-symbol-char { '@' }

token xe-rate
{
    # $830.024 USD
    | <asset-symbol>? <asset-price> \h+ <asset-code>
    # USD $830.024
    | <asset-code> \h+ <asset-symbol>? <asset-price>
}

proto token asset-price {*}
token asset-price:float { <float-unsigned> }
token asset-price:integer { <integer-unsigned> }

# --- --- --- end xe }}}
# --- --- --- inherit {{{

# inherited basis
token inherit
{
    <inherit-symbol> \h+ <inherit-rate=xe-rate>
    { $silo == ASSETS or die(X::TXN::Parser::Annot::Inherit::BadSilo.new) }
}

proto token inherit-symbol {*}
token inherit-symbol:per-unit { <inherit-symbol-char> }
token inherit-symbol:in-total { <inherit-symbol-char> ** 2 }

proto token inherit-symbol-char {*}
token inherit-symbol-char:texas { '<<' }
token inherit-symbol-char:unicode { '«' }

# --- --- --- end inherit }}}
# --- --- --- lot {{{

proto token lot {*}

# lot sales (acquisition)
token lot:acquisition
{
    <lot-acquisition-symbol> \h+ <lot-name>
    { $silo == ASSETS or die(X::TXN::Parser::Annot::Lot::BadSilo.new) }
}

# lot sales (disposition)
token lot:disposition
{
    <lot-disposition-symbol> \h+ <lot-name>
    { $silo == ASSETS or die(X::TXN::Parser::Annot::Lot::BadSilo.new) }
}

proto token lot-acquisition-symbol {*}
token lot-acquisition-symbol:texas { '->' }
token lot-acquisition-symbol:unicode { '→' }

proto token lot-disposition-symbol {*}
token lot-disposition-symbol:texas { '<-' }
token lot-disposition-symbol:unicode { '←' }

token lot-name
{
    '[' \h* <var-name> \h* ']'
}

# --- --- --- end lot }}}

# --- --- end posting annotation grammar }}}

# --- end posting grammar }}}

# end entry grammar }}}
# include grammar {{{

token include-line
{
    ^^ \h* <include> \h* <.comment>? $$
}

proto token include {*}

token include:filename
{
    include \h+ <filename>
}

token include:txnlib
{
    include \h+ <txnlib>
}

token filename
{
    <var-name-string>
}

token txnlib
{
    <txnlib-string>
}

# end include grammar }}}
# ledger grammar {{{

token TOP
{
    <ledger>
}

token ledger
{
    [
        <segment>
        [
            \n <segment>
        ]*
    ]?
    \n?
}

proto token segment {*}
token segment:blank { <.blank-line> }
token segment:comment { <.comment-line> }
token segment:entry { <entry> }
token segment:include { <include-line> }

token blank-line
{
    ^^ \h* $$
}

token comment-line
{
    ^^ \h* <.comment> $$
}

# end ledger grammar }}}

# vim: set filetype=raku foldmethod=marker foldlevel=0:

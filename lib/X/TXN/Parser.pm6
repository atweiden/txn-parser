use v6;

# X::TXN::Parser::Annot::Inherit::BadSilo {{{

class X::TXN::Parser::Annot::Inherit::BadSilo
{
    also is Exception;

    method message(--> Str:D)
    {
        my Str:D $message =
            'Sorry, inherit annotation is only allowed from Assets silo.';
    }
}

# end X::TXN::Parser::Annot::Inherit::BadSilo }}}
# X::TXN::Parser::Annot::Lot::BadSilo {{{

class X::TXN::Parser::Annot::Lot::BadSilo
{
    also is Exception;

    method message(--> Str:D)
    {
        my Str:D $message =
            'Sorry, lot sales annotation is only allowed from Assets silo.';
    }
}

# end X::TXN::Parser::Annot::Lot::BadSilo }}}
# X::TXN::Parser::AssetQuantityIsZero {{{

class X::TXN::Parser::AssetQuantityIsZero
{
    also is Exception;

    has Str:D $.text is required;

    method message(::?CLASS:D: --> Str:D)
    {
        my Str:D $message = qq:to/EOF/.trim;
        Sorry, asset quantity can't be zero. Got 「$.text」
        EOF
    }
}

# end X::TXN::Parser::AssetQuantityIsZero }}}
# X::TXN::Parser::Entry::MultipleEntities {{{

class X::TXN::Parser::Entry::MultipleEntities
{
    also is Exception;

    has Str:D $.entry-text is required;
    has UInt:D $.number-entities is required;

    method message(::?CLASS:D: --> Str:D)
    {
        my Str:D $message = qq:to/EOF/.trim;
        Sorry, only one entity per ledger entry allowed, but found
        $.number-entities entities.

        In entry:

        「{$.entry-text.trim}」
        EOF
    }
}

# end X::TXN::Parser::Entry::MultipleEntities }}}
# X::TXN::Parser::Include {{{

class X::TXN::Parser::Include
{
    also is Exception;

    has Str:D $.filename is required;

    method message(::?CLASS:D: --> Str:D)
    {
        my Str:D $message = qq:to/EOF/.trim;
        Sorry, could not load accounting ledger to include at

            「$.filename」

        Accounting ledger not found or not readable.
        EOF
    }
}

# end X::TXN::Parser::Include }}}
# X::TXN::Parser::ParseFailed {{{

class X::TXN::Parser::ParseFailed
{
    also is Exception;

    has Str:D $.content is required;

    method message(::?CLASS:D: --> Str:D)
    {
        my Str:D $message = qq:to/EOF/.trim;
        Sorry, encountered invalid TXN:

        「{$.content.trim}」
        EOF
    }
}

# end X::TXN::Parser::ParseFailed }}}
# X::TXN::Parser::ParsefileFailed {{{

class X::TXN::Parser::ParsefileFailed
{
    also is Exception;

    has Str:D $.file is required;

    method message(::?CLASS:D: --> Str:D)
    {
        my Str:D $message = "Sorry, encountered invalid TXN in file 「$.file」";
    }
}

# end X::TXN::Parser::ParsefileFailed }}}
# X::TXN::Parser::String::EscapeSequence {{{

class X::TXN::Parser::String::EscapeSequence
{
    also is Exception;

    has Str:D $.esc is required;

    method message(::?CLASS:D: --> Str:D)
    {
        my Str:D $message = "Sorry, found bad string escape sequence 「$.esc」";
    }
}

# end X::TXN::Parser::String::EscapeSequence }}}
# X::TXN::Parser::TXNLibAbsolute {{{

class X::TXN::Parser::TXNLibAbsolute
{
    also is Exception;

    has Str:D $.lib is required;

    method message(::?CLASS:D: --> Str:D)
    {
        my Str:D $message =
            "Sorry, txnlib path can't be absolute. Got:「$.lib」";
    }
}

# end X::TXN::Parser::TXNLibAbsolute }}}

# vim: set filetype=raku foldmethod=marker foldlevel=0:

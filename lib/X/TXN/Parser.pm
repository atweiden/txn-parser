use v6;
unit class X::TXN::Parser;

# X::TXN::Parser::Entry::MultipleEntities {{{

class Entry::MultipleEntities is Exception
{
    has Str $.entry-text;
    has Int $.number-entities;

    method message()
    {
        say qq:to/EOF/;
        Sorry, only one entity per journal entry allowed, but found
        $.number-entities entities.

        In entry:

        「$.entry-text」
        EOF
    }
}

# end X::TXN::Parser::Entry::MultipleEntities }}}

# X::TXN::Parser::Extends {{{

class Extends is Exception
{
    has Str $.journalname;

    method message()
    {
        say qq:to/EOF/;
        Sorry, could not locate transaction journal to extend

            「$.journalname」
        EOF
    }
}

# end X::TXN::Parser::Extends }}}

# X::TXN::Parser::Include {{{

class Include is Exception
{
    has Str $.filename;

    method message()
    {
        say qq:to/EOF/;
        Sorry, could not load transaction journal to include at

            「$.filename」

        Transaction journal not found or not readable.
        EOF
    }
}

# end X::TXN::Parser::Include }}}

# vim: ft=perl6 fdm=marker fdl=0

/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import anhnhan.parser.parsec.string {
    skipWhitespace
}

import ceylon.test {
    test
}

shared
ParseResult<Atom[], {Atom*}> filterEmpty<Atom>(ParseResult<Atom[], {Atom*}> _result)
        given Atom satisfies Object
        => bindOk((Ok<Atom[], {Atom*}> _result) => ok(result(_result).select((Atom atom) => [].equals(atom)), rest(_result)))(_result);

test
void testFilterEmpty()
{
    value str1 = "a b c d";
    value parser1 = sequence<Character>(literal('a'), skipWhitespace, skip(literal('b')), literal(' '));
}

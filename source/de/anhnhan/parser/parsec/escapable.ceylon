/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.collection {
    HashMap
}
import ceylon.test {
    test,
    assertEquals
}

shared
Parser<Literal[], InputElement> escapeBetween<Literal, DelimLiteral, InputElement>(
    Parser<Literal, InputElement> escapeP,
    Parser<DelimLiteral, InputElement> delimP,
    Parser<Literal, InputElement> inner,
    Literal(Literal) escapeApply = identity<Literal>,
    Parser<DelimLiteral, InputElement> delimRP = delimP
)
        => between(delimP, or(apply(right(escapeP, inner), escapeApply), inner), delimRP);

test
void testEscapeBetween()
{
    value str = "'text\\'\\t\\\\\\' \\''not-in-quotes''";
    value parse = escapeBetween(
        literal('\\'),
        literal('\''),
        anyLiteral<Character>,
        (Character lit)
        {
            return HashMap { entries = {
                't' -> '\t',
                'n' -> '\n'
            }; }.get(lit) else lit;
        }
    );

    value result = parse(str);
    assert(is Ok<Anything, Character> result);
    assertEquals(result.result, ['t', 'e', 'x', 't', '\'', '\t', '\\', '\'', ' ', '\'']);
    assertEquals(result.rest, "not-in-quotes''");
}

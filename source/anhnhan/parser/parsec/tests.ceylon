/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import anhnhan.parser.parsec.string {
    skipWhitespace
}

import ceylon.test {
    test,
    assertEquals,
    fail
}

test
void test0001()
{
    value str1 = "a b c d";
    value parser1 = sequence<Character|Anything[], Character>(literal('a'), skipWhitespace, skip(literal('b')), literal(' '));

    value result1 = parser1(str1);
    assertEquals(result1, ok(['a', [], [], ' '], "c d"));

    value filtered1 = filterEmpty<Character|Anything[], Character>(result1);
    bind<Character|Anything[], Character, Anything, Anything> {
        (Ok<Character|Anything[], Character> ok) => assertEquals(result(ok), ['a', ' ']);
        (Anything error) => fail();
    } (filtered1);
}

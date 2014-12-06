/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.test {
    test,
    assertEquals
}

"""Parses a single literal and returns it upon success, else it returns
   [[failure]].

       value parse = lit<Character, {Character*}>('a');
       Character result1 = parse("abc");
       assert(result1 == 'a');
       Failure result2 = parse("foo");
       assert(result2 == failure);"""
shared MaybeLiteral<T, Input> lit<T, Input>(T literal)(Input input)
    given T satisfies Object
    given Input satisfies {T*}
{
    if (exists first = input.first, first == literal)
    {
        "Our upper bound of [[Iterable]] specifies that [[Iterable.rest]]
         returns [[Iterable]], but this will not satisfy our upper bound."
        assert(is Input rest = input.rest);

        return [literal, rest];
    }

    return failure;
}

"Convenience type-applied function for parsing single characters."
shared MaybeLiteral<Character, {Character*}>({Character*})(Character) litChar
    => lit<Character, {Character*}>;

"Convenience function to parse a string of characters, but to have integers
 as the result."
shared MaybeLiteral<Integer, {Character*}>({Character*}) litCharToInt(Character char)
        => apply(Character.integer, litChar(char));

test
void testLit()
{
    value parse = litChar('a');

    assertEquals(parse("abc"), ['a', "bc"]);
    assertEquals(parse("acd"), ['a', "cd"]);
    assertEquals(parse("a"), ['a', ""]);

    assertEquals(parse("foo"), failure);
}

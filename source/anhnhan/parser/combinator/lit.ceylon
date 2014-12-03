/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

"""Parses a single literal and returns it upon success, else it returns
   [[failure]].

       value parse = lit<Character, {Character*}>('a');
       Character result1 = parse("abc");
       assert(result1 == 'a');
       Failure result2 = parse("foo");
       assert(result2 == failure);"""
// TODO: Advance parser input state
shared Failable<T> lit<T, Ts>(T literal)(Ts input)
    given T satisfies Object
    given Ts satisfies {T*}
{
    if (exists first = input.first, first == literal)
    {
        return literal;
    }

    return failure;
}

"Convenience type-applied function for parsing single characters."
shared Failable<Character>({Character*})(Character) litChar
    => lit<Character, {Character*}>;

"Convenience function to parse a string of characters, but to have integers
 as the result."
shared Failable<Integer>({Character*}) litCharToInt(Character char)
        => apply(Character.integer, litChar(char));

void testLit()
{
    value parse = lit<Character, {Character*}>('a');

    value result1 = parse("abc");
    assert(result1 == 'a');

    value result2 = parse("foo");
    assert(result2 == failure);
}

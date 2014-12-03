/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.test {
    assertEquals
}

// TODO: Advance parser input state
shared Failable<[T, T]> and<T, Ts>(Failable<T>(Ts) fun1, Failable<T>(Ts) fun2)(Ts input)
    given T satisfies Object
    given Ts satisfies {T*}
{
    if (is T first = fun1(input), is T second = fun2(input))
    {
        return [first, second];
    }

    return failure;
}

void test1()
{
    value literal = lit<Character, {Character*}>;
    value parser1 = and(literal('a'), literal('b'));
    value parser2 = or(
        and(literal('a'), literal('b')),
        and(literal('c'), literal('d'))
    );

    assertEquals(parser1("abc"), ['a', 'b']);
    assertEquals(parser1("foo"), failure);

    assertEquals(parser2("abcd"), ['c', 'd']);
}

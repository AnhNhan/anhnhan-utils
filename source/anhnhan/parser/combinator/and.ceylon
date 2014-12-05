/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.collection {
    LinkedList
}
import ceylon.test {
    assertEquals,
    test
}

shared MaybeLiteral<[T, T], Ts> and<T, Ts>(MaybeLiteral<T, Ts>(Ts) fun1, MaybeLiteral<T, Ts>(Ts) fun2)(Ts input)
    given T satisfies Object
    given Ts satisfies {T*}
{
    if (is LiteralResult<T, Ts> first = fun1(input), is LiteralResult<T, Ts> second = fun2(first[1]))
    {
        return [[first[0], second[0]], second[1]];
    }

    return failure;
}

shared MaybeLiteral<{T*}, InputAndRest> sequence<T, InputAndRest>(MaybeLiteral<T, InputAndRest>(InputAndRest)+ parsers)(InputAndRest input)
    given T satisfies Object
    given InputAndRest satisfies {T*}
{
    variable value _input = input;
    value results = LinkedList<T>();

    for (parser in parsers)
    {
        value result = parser(_input);
        if (is LiteralResult<T, InputAndRest> result)
        {
            results.add(result[0]);
            _input = result[1];
        }
        else
        {
            return failure;
        }
    }

    return [results, _input];
}

test
void testAnd()
{
    value parser1 = and(litChar('a'), litChar('b'));

    assertEquals(parser1("abc"), [['a', 'b'], "c"]);
    assertEquals(parser1("foo"), failure);
    assertEquals(parser1("ac"), failure);

    value parser2 = or(
        and(litChar('a'), litChar('b')),
        and(litChar('c'), litChar('d'))
    );
    assertEquals(parser2("ab"), [['a', 'b'], ""]);
    assertEquals(parser2("cd"), [['c', 'd'], ""]);
    assertEquals(parser2("ac"), failure);

    // This is a little bit unwieldy - use sequence instead!
    value parser3 = and(
        litChar('a'),
        and(litChar('b'),
            and(litChar('c'), litChar('d'))
        )
    );
    assertEquals(parser3("abcde"), [['a', ['b', ['c', 'd']]], "e"]);
    assertEquals(parser3("abc"), failure);
}

test
void testSequence()
{
    value parser1 = sequence(litChar('a'), litChar('b'), litChar('c'), litChar('d'));

    value result = parser1("abcdefg");
    assert(is LiteralResult<{Character*}, {Character*}> result);
    value expected = [{'a', 'b', 'c', 'd'}, "efg"];
    print(result[0]);
    print(expected[0]);
    assertEquals(result[0], expected[0]);
    assertEquals(result[1], expected[1]);
    //assertEquals(parser1("abcdefg"), [{'a', 'b', 'c', 'd'}, "efg"]);

    assertEquals(parser1("foo"), failure);
}
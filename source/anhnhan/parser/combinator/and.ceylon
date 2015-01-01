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
    test,
    assertTrue
}

shared MaybeLiteral<[T, T], Input> and<T, Input>(MaybeLiteral<T, Input>(Input) fun1, MaybeLiteral<T, Input>(Input) fun2)(Input input)
    given T satisfies Object
    given Input satisfies {T*}
{
    if (is Ok<T, Input> first = fun1(input), is Ok<T, Input> second = fun2(first[1]))
    {
        return [[first[0], second[0]], second[1]];
    }

    return failure;
}

shared MaybeLiteral<T[], Input> sequence<T, Input>(MaybeLiteral<T, Input>(Input)+ parsers)(Input input)
    given T satisfies Object
    given Input satisfies {T*}
{
    variable value _input = input;
    value results = LinkedList<T>();

    for (parser in parsers)
    {
        if (is Ok<T, Input> result = parser(_input))
        {
            results.add(result[0]);
            _input = result[1];
        }
        else
        {
            return failure;
        }
    }

    "There should be at least one result from parsing."
    assert(nonempty sequence = results.sequence());

    return [sequence, _input];
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
    assert(is Ok<Character[], {Character*}> result);
    value expected = [{'a', 'b', 'c', 'd'}.sequence(), "efg"];
    assertTrue({for (index->res in result[0].indexed) res == (expected[0][index] else nothing)}.every(identity<Boolean>));
    assertEquals(result[0], expected[0]);
    assertEquals(result[1], expected[1]);
    //assertEquals(parser1("abcdefg"), [{'a', 'b', 'c', 'd'}, "efg"]);

    assertEquals(parser1("foo"), failure);
}

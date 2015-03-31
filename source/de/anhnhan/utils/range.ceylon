/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.collection {
    group
}
import ceylon.test {
    assertEquals,
    test
}

shared {Elements*} chainAll<Elements>({Elements*}+ iterators)
    given Elements satisfies Object
{
    if (iterators.size == 1)
    {
        return iterators.first;
    }

    variable value iterator = iterators.first;
    variable value _iterators = iterators.rest;

    while (exists next = _iterators.first)
    {
        iterator = iterator.chain(next);
        _iterators = _iterators.rest;
    }

    return iterator;
}

shared String joinStrings({String*} strings, String joinWith = "\n")
    => strings.interpose(joinWith).reduce((String? partial, String element) => (partial else "") + element) else "";

shared Element joinAll<Element>({Element+} elements)
    given Element satisfies Summable<Element>
    => elements.reduce((Element partial, Element element) => partial + element);

shared Element transposeAndJoin<Element>(Element interpose)({Element+} elements)
    given Element satisfies Summable<Element>
{
    value _ = elements.interpose(interpose).sequence();
    assert(nonempty _);
    return joinAll(_);
}

"This function assumes a reasonable equality behavior for the given types."
shared Map<Element, [Element+]> duplicates<Element>({Element*} input)
        given Element satisfies Object
        => group(input, identity<Element>);

shared Element|Absent pick_random<Element, Absent>(
    Iterable<Element, Absent> list,
    "An RNG function or delegate with a range of 0..[[maximum]]-1."
    Integer random(Integer maximum)
)
        given Absent satisfies Null
{
    switch (list.size)
    case (0)
    {
        // Ohhhh.....
        assert(is Absent null);
        return null;
    }
    case (1)
    {
        return list.first;
    }
    else
    {
        assert(is Element|Absent val = list.getFromFirst(random(list.size)));
        return val;
    }
}

"Inserts the given [[element]] after the [[nth|index]] element in a given [[list]],
 leaving the original list untouched (but retaining its elements).

 Passing 0 to [[index]] inserts the element at the beginning of the list,
 passing a value equal or greater than `list.size` will append the element to
 the list."
shared Iterable<Element|Insertion, Nothing> insertAt<Element, Insertion>({Element*} list, Integer index, Insertion element)
        => list.take(index).chain({element, *list.skip(index)});

test
void testInsertAt()
{
    assertEquals(insertAt([1, 2, 4], 2, 3).sequence(), [1, 2, 3, 4]);
    assertEquals(insertAt([1, 2, 4], 0, 3).sequence(), [3, 1, 2, 4]);
    assertEquals(insertAt([1, 2, 4], 3, 3).sequence(), [1, 2, 4, 3]);
    assertEquals(insertAt([], 2, 3).sequence(), [3]);
}

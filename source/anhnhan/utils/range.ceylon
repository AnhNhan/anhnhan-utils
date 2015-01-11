/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

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

shared Element|Absent pick_random<Element, Absent>(Iterable<Element, Absent> list, Integer random(Integer maximum))
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

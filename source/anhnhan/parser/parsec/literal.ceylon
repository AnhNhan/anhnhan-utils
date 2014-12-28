/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.test {
    test,
    assertEquals
}

shared
ParseResult<Atom, {Atom*}> literal<Atom>(Atom atom)({Atom*} str)
        given Atom satisfies Object
{
    if (exists first = str.first, first == atom)
    {
        return [first, str.rest];
    }

    return ExpectedLiteral(atom, str.first, str);
}

test
void testLiteral()
{
    value parse = literal('a');

    assertEquals(parse("abc"), ok('a', "bc"));
    assertEquals(parse("acd"), ok('a', "cd"));
    assertEquals(parse("a"), ok('a', ""));

    assertEquals(parse("foo"), ExpectedLiteral('a', 'f', "foo"));
}

shared
ParseResult<Anything[], {Atom*}> skipLiteral<Atom, String>(Atom atom)(String str)
        given Atom satisfies Object
        given String satisfies {Atom*}
{
    if (is Ok<Atom, {Atom*}> lit = literal(atom)(str))
    {
        // TODO: Nothing legit?
        return [[], rest(lit)];
    }

    [Atom]|[] instead;
    if (exists first = str.first)
    {
        instead = [first];
    }
    else
    {
        instead = [];
    }

    return ExpectedLiteral([atom], instead, str);
}

test
void testSkipLiteral()
{
    value parser = skipLiteral<Character, {Character*}>('a');

    assertEquals(parser("abc"), ok([], "bc"));
    assertEquals(parser("bc"), ExpectedLiteral(['a'], ['b'], "bc"));
    assertEquals(parser(""), ExpectedLiteral(['a'], [], ""));
}

shared
ParseResult<Atom, {Atom*}> anyLiteral<Atom>({Atom*} str)
        given Atom satisfies Object
{
    if (exists nextLiteral = str.first)
    {
        return ok(nextLiteral, str.rest);
    }

    return JustError(str);
}

shared
ParseResult<Anything[], {Atom*}> emptyLiteral<Atom>({Atom*} str)
        given Atom satisfies Object
{
    if (exists nextLiteral = str.first)
    {
        return JustError(str);
    }

    return ok([], str);
}

shared
ParseResult<Atom, {Atom*}> matchAtomIf<Atom>(Boolean(Atom) predicate)({Atom*} str)
        given Atom satisfies Object
{
    if (exists first = str.first, predicate(first))
    {
        return ok(first, str.rest);
    }

    return JustError(str);
}

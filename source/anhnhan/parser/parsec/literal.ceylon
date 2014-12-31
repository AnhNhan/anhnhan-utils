/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.test {
    test,
    assertEquals
}

"Parses a single literal, and returns it."
shared
ParseResult<Atom, {Atom*}> literal<Atom>(Atom atom)({Atom*} str)
        given Atom satisfies Object
{
    if (exists first = str.first, first == atom)
    {
        return [first, str.rest];
    }

    return ExpectedLiteral(atom, str.first, str, ["Expected '``atom``', but got '``str.first else "<null>"``'"]);
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

"Optimized version for skipping a single literal."
shared
ParseResult<Anything[], {Atom*}> skipLiteral<Atom, String>(Atom atom)(String str)
        given Atom satisfies Object
        given String satisfies {Atom*}
{
    if (is Ok<Atom, {Atom*}> lit = literal(atom)(str))
    {
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

    return ExpectedLiteral<Atom[], {Atom*}>([atom], instead, str, ["Can't skip single literal. Expected '``atom``', but got '``instead.first else "<null>"``'"]);
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

// TODO: Consider U+FFFF as valid EOS, too?
shared
ParseResult<Atom[], Atoms> emptyLiteral<Atom, Atoms>(Atoms str)
        given Atom satisfies Object
        given Atoms satisfies {Atom*}
{
    if (exists nextLiteral = str.first)
    {
        return JustError(str, ["Expected the end of the string."]);
    }

    return ok([], str);
}

test
void testEmpty()
{
    assertEquals(emptyLiteral(""), ok([], ""));
    assertEquals(emptyLiteral("abc"), JustError("abc"));
}

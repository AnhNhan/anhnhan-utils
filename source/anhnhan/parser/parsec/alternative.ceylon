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
ParseResult<Atom, {Atom*}> or<Atom>(ParseResult<Atom, {Atom*}>({Atom*}) first, ParseResult<Atom, {Atom*}>({Atom*}) second)({Atom*} input)
        given Atom satisfies Object
        => bind<Atom, {Atom*}, Ok<Atom, {Atom*}>, ParseResult<Atom, {Atom*}>> {
                identity<Ok<Atom, {Atom*}>>;
                (error) => second(input);
            } (first(input));

test
void testOr()
{
    value parseA = literal('a');
    value parseB = literal('b');
    value parseC = literal('c');

    value ab  = or<Character>(parseA, parseB);
    value abc = or<Character>(parseA, or<Character>(parseB, parseC));

    assertEquals(ab("abc"), ['a', "bc"]);
    assertEquals(ab("bc"), ['b', "c"]);
    assertEquals(abc("c"), ['c', ""]);
}

shared
ParseResult<Atom, {Atom*}> anyOf<Atom>(parsers)({Atom*} input)
        given Atom satisfies Object
{
    ParseResult<Atom, {Atom*}>({Atom*})+ parsers;
    variable Error<Atom, {Atom*}>[] errors = [];

    for (parser in parsers)
    {
        value _result = parser(input);
        switch (_result)
        case (is Ok<Atom, {Atom*}>)
        {
            return ok(result(_result), rest(_result));
        }
        case (is Error<Atom, {Atom*}>)
        {
            errors = [_result, *errors];
        }
    }

    // Ain't this a little bit expensive? Try to make this lazier (e.g. in the string concat below).
    value _errors = errors.indexed.map((entry) => "``entry.key.string.padLeading(4)`` - ``entry.item``");

    return JustError(input, ["No viable match.", *_errors]);
}

shared
ParseResult<Atom, {Atom*}> atomFromCategory<Atom>({Atom*} list)({Atom*} str)
        given Atom satisfies Object
{
    value nextAtom = str.first;
    if (exists nextAtom, nextAtom in list)
    {
        return ok(nextAtom, str.rest);
    }

    return ExpectedLiteral<Atom, {Atom*}>(list, nextAtom, str);
}

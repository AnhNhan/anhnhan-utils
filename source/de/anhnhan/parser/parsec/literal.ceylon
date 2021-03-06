/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.collection {
    LinkedList
}
import ceylon.test {
    test,
    assertEquals
}

"Parses a single literal, and returns it."
shared
ParseResult<Literal, Literal> literal<Literal>(Literal atom)({Literal*} str)
        given Literal satisfies Object
{
    if (exists first = str.first, first == atom)
    {
        return ok(first, str.rest);
    }

    return ExpectedLiteral(atom, str.first, str, ["Expected '``atom``', but got '``str.first else "<end of input>"``'"]);
}

test
void testLiteral()
{
    value parse = literal('a');

    assertEquals(parse("abc"), ok('a', "bc"));
    assertEquals(parse("acd"), ok('a', "cd"));
    assertEquals(parse("a"), ok('a', ""));

    assertEquals(parse("foo"), ExpectedLiteral('a', 'f', "foo"));

    value parse2 = literal(1);

    assertEquals(parse2([1, 2, 3]), ok(1, [2, 3]));
    assertEquals(parse2([2, 3]), ExpectedLiteral(1, 2, [2, 3]));
}

shared
ParseResult<[Literal+], Literal> literals<Literal>(List<Literal> literals, Integer insteadTakeExtra = 5)({Literal*} input)
        given Literal satisfies Object
{
    value sequence = literals.sequence();
    assert (nonempty sequence);
    value str = input.take(literals.size);
    [Literal+]? instead;
    if (nonempty _instead = input.take(literals.size + insteadTakeExtra).sequence())
    {
        instead = _instead;
    }
    else
    {
        instead = null;
    }
    value error = ExpectedLiteral<[Literal+], Literal>(sequence, instead, input);

    if (str.size.smallerThan(literals.size))
    {
        return error.appendMessage("Unexpected end of input.");
    }

    if (!literals.startsWith(LinkedList(str)))
    {
        return error.appendMessage("Input does not match.");
    }

    return ok(sequence, input.skip(literals.size));
}

"Optimized version for skipping a single literal."
shared
ParseResult<Literal[], Literal> skipLiteral<Literal>(Literal atom)({Literal*} str)
        given Literal satisfies Object
{
    value first = str.first;
    if (exists first, first == atom)
    {
        return ok([], str.rest);
    }

    [Literal]? instead;
    if (exists first)
    {
        instead = [first];
    }
    else
    {
        instead = null;
    }

    return ExpectedLiteral<Literal[], Literal>([atom], instead, str, ["Can't skip single literal. Expected '``atom``', but got '``instead else "<end of input>"``'"]);
}

test
void testSkipLiteral()
{
    value parser = skipLiteral('a');

    assertEquals(parser("abc"), ok([], "bc"));
    assertEquals(parser("bc"), ExpectedLiteral<Character[], Character>(['a'], ['b'], "bc"));
    assertEquals(parser(""), ExpectedLiteral<Character[], Character>(['a'], [], ""));
}

shared
ParseResult<Literal, Literal> anyLiteral<Literal>({Literal*} str)
        given Literal satisfies Object
{
    if (exists nextLiteral = str.first)
    {
        return ok(nextLiteral, str.rest);
    }

    return JustError(str, ["Encountered end of input. Expected anything but that."]);
}

// TODO: Consider U+FFFF as valid EOS, too?
shared
ParseResult<Literal[], Literal> emptyLiteral<Literal>({Literal*} str)
        given Literal satisfies Object
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

// TODO: Normalize newlines?
"Parses a single literal if a given [[predicate]] applies."
shared
ParseResult<InputElement, InputElement> satisfy<InputElement>(Boolean(InputElement) predicate, String label = "")({InputElement*} input)
{
    if (exists nextLiteral = input.first, predicate(nextLiteral))
    {
        return ok(nextLiteral, input.rest);
    }

    return JustError(input, ["Did not satisfy predicate " + label]);
}

"At least one satisfied."
shared
ParseResult<[InputElement+], InputElement> manySatisfy<InputElement>(Boolean(InputElement) predicate, String label = "")({InputElement*} input)
{
    value satisfyF = satisfy(predicate, label);

    value list = LinkedList<InputElement>();
    variable
    value _input = input;
    variable
    value _result = satisfyF(_input);

    while (is Ok<InputElement, InputElement> __result = _result)
    {
        _input = __result.rest;
        list.add(__result.result);
        _result = satisfyF(_input);
    }

    value seq = list.sequence();
    if (nonempty seq)
    {
        return ok(seq, _input);
    }
    else
    {
        return JustError(input, ["Did not satisfy predicate " + label]);
    }
}

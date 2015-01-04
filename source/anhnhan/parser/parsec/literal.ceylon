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
        return [first, str.rest];
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
ParseResult<Literal[], Literal> literals<Literal>([Literal+] literals, Integer insteadTakeExtra = 5)({Literal*} input)
        given Literal satisfies Object
{
    value str = input.take(literals.size);
    value error = addMessage2(ExpectedLiteral<Literal[], Literal>(literals, input.take(literals.size + insteadTakeExtra).sequence(), input));

    if (str.size.smallerThan(literals.size))
    {
        return error("Unexpected end of input.");
    }

    if (str != literals)
    {
        return error("Input does not match");
    }

    return ok(literals, input.skip(literals.size));
}

"Optimized version for skipping a single literal."
shared
ParseResult<Anything[], Literal> skipLiteral<Literal>(Literal atom)({Literal*} str)
        given Literal satisfies Object
{
    value first = str.first;
    if (exists first, first == atom)
    {
        return [[], str.rest];
    }

    [Literal]|[] instead;
    if (exists first)
    {
        instead = [first];
    }
    else
    {
        instead = [];
    }

    return ExpectedLiteral<Literal[], Literal>([atom], instead, str, ["Can't skip single literal. Expected '``atom``', but got '``instead.first else "<end of input>"``'"]);
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

    return JustError(str);
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
        given InputElement satisfies Object
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
        given InputElement satisfies Object
{
    value satisfyF = satisfy(predicate, label);

    value list = LinkedList<InputElement>();
    variable
    value _input = input;
    variable
    value _result = satisfyF(_input);

    while (is Ok<InputElement, InputElement> __result = _result)
    {
        _input = rest(__result);
        list.add(result(__result));
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

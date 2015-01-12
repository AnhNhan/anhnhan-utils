/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import anhnhan.parser.parsec.string {
    letter
}

import ceylon.collection {
    LinkedList
}
import ceylon.test {
    test,
    assertEquals
}

"Similar to `between`, but also returns the delimeters."
shared
ParseResult<[DelimLiteral, InnerLiteral[], DelimLiteral], InputElement> enclosedBy<DelimLiteral, InnerLiteral, InputElement>(delim, inner, delimRight = delim)({InputElement*} input)
{
    Parser<DelimLiteral, InputElement> delim;
    Parser<InnerLiteral, InputElement> inner;
    Parser<DelimLiteral, InputElement> delimRight;

    value delimResult = delim(input);
    if (is Error<DelimLiteral, InputElement> delimResult)
    {
        return delimResult.toJustError.appendMessage("Missing starting delimeter in enclosing parse.");
    }
    assert(is Ok<DelimLiteral, InputElement> delimResult);

    value _inners = LinkedList<InnerLiteral>();
    variable
    value _input = delimResult.rest;
    while (is Error<InnerLiteral, InputElement> nonDelimParse = delimRight(_input))
    {
        value innerR = inner(_input);
        switch (innerR)
        case (is Ok<InnerLiteral, InputElement>)
        {
            _input = innerR.rest;
            _inners.add(innerR.result);
        }
        case (is Error<InnerLiteral, InputElement>)
        {
            return PointOutTheError(input.take(input.size - innerR.rest.size), innerR.rest, ["Couldn't parse the contents of the enclosing parse."]);
        }
    }
    value inners = ok(_inners.sequence(), _input);

    value delimRightResult = delimRight(inners.rest);
    if (is Error<DelimLiteral, InputElement> delimRightResult)
    {
        return PointOutTheError(input.take(input.size - delimRightResult.rest.size), delimRightResult.rest, ["Missing ending delimeter in enclosing parse."]);
    }
    assert(is Ok<DelimLiteral, InputElement> delimRightResult);

    return ok([delimResult.result, inners.result, delimRightResult.result], delimRightResult.rest);
}

test
void testEnclosedBy()
{
    value input1 = "()abc()";
    value input2 = {0, 9, 1, 2, 3, 0, 9};
    value input3 = {0, 9, 1, 2, 3, 9, 0};

    value parse1 = enclosedBy(and(literal('('), literal(')')), letter);
    value parse2 = enclosedBy(and(literal(0), literal(9)), satisfy((Integer x) => x in [1, 2, 3]));
    value parse3 = enclosedBy(and(literal(0), literal(9)), satisfy((Integer x) => x in [1, 2, 3]), and(literal(9), literal(0)));

    assert(is Ok<Character[][], Character> result1 = parse1(input1));
    assert(is Ok<Integer[][], Integer> result2 = parse2(input2));
    assert(is Ok<Integer[][], Integer> result3 = parse3(input3));

    // Checking only one result, it's tedious.
    assertEquals(result1, ok([['(', ')'], ['a', 'b', 'c'], ['(', ')']], ""));
}

shared
Parser<[InputElement, InnerLiteral[], InputElement], InputElement> enclosedByLiteral<InnerLiteral, InputElement>(InputElement delim, Parser<InnerLiteral, InputElement> inner, InputElement delimRight = delim)
        given InnerLiteral satisfies Object
        given InputElement satisfies Object
        => enclosedBy(literal(delim), inner, literal(delimRight));

test
void testEnclosedByLiteral()
{
    value input1_1 = "(abc)";
    value input1_2 = "(a,b)";
    value parse1 = enclosedByLiteral('(', letter, ')');

    assertEquals(parse1(input1_1), ok(['(', ['a', 'b', 'c'], ')'], ""));

    assert(is Error<Character, Character> result1_2 = parse1(input1_2));
}

"[[inner]] is possibly-empty."
shared
ParseResult<InnerLiteral[], InputElement> between<DelimLiteral, InnerLiteral, InputElement>(delim, inner, delimRight = delim)({InputElement*} input)
{
    Parser<DelimLiteral, InputElement> delim;
    Parser<InnerLiteral, InputElement> inner;
    Parser<DelimLiteral, InputElement> delimRight;

    value result = enclosedBy(delim, inner, delimRight)(input);

    switch (result)
    case (is Ok<[DelimLiteral, InnerLiteral[], DelimLiteral], InputElement>)
    {
        return ok(result.result[1], result.rest);
    }
    case (is Error<Anything, InputElement>)
    {
        return result.toJustError;
    }
}

shared
Parser<InnerLiteral[], InputElement> betweenLiteral<InnerLiteral, InputElement>(InputElement delim, Parser<InnerLiteral, InputElement> inner, InputElement delimRight = delim)
        given InnerLiteral satisfies Object
        given InputElement satisfies Object
        => between(literal(delim), inner, literal(delimRight));

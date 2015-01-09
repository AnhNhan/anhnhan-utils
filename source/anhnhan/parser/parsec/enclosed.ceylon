/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import anhnhan.parser.parsec.string {
    letter
}

import ceylon.test {
    test,
    assertEquals
}

"Similar to `between`, but also returns the delimeters."
shared
Ok<[DelimLiteral, InnerLiteral[], DelimLiteral], InputElement>|Error<DelimLiteral, InputElement> enclosedBy<DelimLiteral, InnerLiteral, InputElement>(delim, inner, delimRight = delim)({InputElement*} input)
        given InnerLiteral satisfies Object
        given DelimLiteral satisfies Object
{
    Parser<DelimLiteral, InputElement> delim;
    Parser<InnerLiteral, InputElement> inner;
    Parser<DelimLiteral, InputElement> delimRight;

    value delimResult = delim(input);
    if (is Error<DelimLiteral, InputElement> delimResult)
    {
        return delimResult.appendMessage("Missing starting delimeter in enclosing parse.");
    }
    assert(is Ok<DelimLiteral, InputElement> delimResult);

    value inners = zeroOrMore(inner)(delimResult.rest);

    value delimRightResult = delimRight(inners.rest);
    if (is Error<DelimLiteral, InputElement> delimRightResult)
    {
        return MultitudeOfErrors([delimRightResult, PointOutTheError(input.take(input.size - delimRightResult.rest.size), delimRightResult.rest)], ["Missing ending delimeter in enclosing parse."]);
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
Ok<[InputElement, InnerLiteral[], InputElement], InputElement>|Error<InputElement, InputElement> enclosedByLiteral<InnerLiteral, InputElement>(delim, inner, delimRight = delim)({InputElement*} input)
        given InnerLiteral satisfies Object
        given InputElement satisfies Object
{
    InputElement delim;
    Parser<InnerLiteral, InputElement> inner;
    InputElement delimRight;

    value delimP = literal(delim);
    value delimRP = literal(delimRight);

    value delimResult = delimP(input);
    if (is Error<InputElement, InputElement> delimResult)
    {
        return delimResult.appendMessage("Missing starting delimeter in enclosing parse.");
    }
    assert(is Ok<InputElement, InputElement> delimResult);

    value inners = zeroOrMore(inner)(delimResult.rest);

    value delimRightResult = delimRP(inners.rest);
    if (is Error<InputElement, InputElement> delimRightResult)
    {
        return MultitudeOfErrors([delimRightResult, PointOutTheError(input.take(input.size - delimRightResult.rest.size), delimRightResult.rest)], ["Missing ending delimeter in enclosing parse."]);
    }
    assert(is Ok<InputElement, InputElement> delimRightResult);

    return ok([delimResult.result, inners.result, delimRightResult.result], delimRightResult.rest);
}

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
Ok<InnerLiteral[], InputElement>|Error<DelimLiteral, InputElement> between<DelimLiteral, InnerLiteral, InputElement>(delim, inner, delimRight = delim)({InputElement*} input)
        given InnerLiteral satisfies Object
        given DelimLiteral satisfies Object
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
    case (is Error<DelimLiteral, InputElement>)
    {
        return result;
    }
}

shared
Ok<InnerLiteral[], InputElement>|Error<InputElement, InputElement> betweenLiteral<InnerLiteral, InputElement>(InputElement delim, Parser<InnerLiteral, InputElement> inner, InputElement delimRight = delim)({InputElement*} input)
        given InnerLiteral satisfies Object
        given InputElement satisfies Object
        => between(literal(delim), inner, literal(delimRight))(input);

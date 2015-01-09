/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.collection {
    LinkedList
}

shared
ParseResult<[FirstLiteral, SecondLiteral], InputElement> and<FirstLiteral, SecondLiteral, InputElement>(firstP, secondP)({InputElement*} input)
        given FirstLiteral satisfies Object
        given SecondLiteral satisfies Object
{
    Parser<FirstLiteral, InputElement> firstP;
    Parser<SecondLiteral, InputElement> secondP;

    value firstR = firstP(input);
    switch (firstR)
    case (is Ok<FirstLiteral, InputElement>)
    {
        value secondR = secondP(firstR.rest);
        switch (secondR)
        case (is Ok<SecondLiteral, InputElement>)
        {
            return ok([firstR.result, secondR.result], secondR.rest);
        }
        case (is Error<SecondLiteral, InputElement>)
        {
            return toJustError(secondR);
        }
    }
    case (is Error<FirstLiteral, InputElement>)
    {
        return toJustError(firstR);
    }
}

shared
ParseResult<Literal[], InputElement> sequence<Literal, InputElement>(parsers)({InputElement*} input)
        given Literal satisfies Object
{
    Parser<Literal, InputElement>+ parsers;
    variable value _input = input;
    value results = LinkedList<Literal>();

    for (parser in parsers)
    {
        value _result = parser(_input);
        if (is Ok<Literal, InputElement> _result)
        {
            _input = _result.rest;
            results.add(_result.result);
        }
        else
        {
            return PointOutTheError(input.take(_result.rest.size), _result.rest);
        }
    }

    // TODO: Filter out [] instances coming from skip
    return ok(results.sequence(), _input);
}

shared
Ok<Literal[], InputElement> zeroOrMore<Literal, InputElement>(Parser<Literal, InputElement> parser)({InputElement*} str)
        given Literal satisfies Object
{
    variable value _input = str;
    value results = LinkedList<Literal>();

    while (is Ok<Literal, InputElement> _result = parser(_input))
    {
        results.add(_result.result);
        _input = _result.rest;
    }

    // TODO: Filter out [] instances coming from skip
    return ok(results.sequence(), _input);
}

// Success may be skewed due to possibly containing empty results.
shared
ParseResult<[Literal+], InputElement> oneOrMore<Literal, InputElement>(Parser<Literal, InputElement> parser)({InputElement*} str)
        given Literal satisfies Object
{
    value results = zeroOrMore<Literal, InputElement>(parser)(str);
    if (nonempty literal = results.result)
    {
        return ok(literal, results.rest);
    }
    else
    {
        return JustError(str);
    }
}

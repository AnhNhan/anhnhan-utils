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
{
    Parser<FirstLiteral, InputElement> firstP;
    Parser<SecondLiteral, InputElement> secondP;

    return firstP(input).bind {
        (firstR) => secondP(firstR.rest).bind {
            (secondR) => ok([firstR.result, secondR.result], secondR.rest);
            (error) => error.toJustError;
        };
        (error) => error.toJustError;
    };
}

shared
ParseResult<Literal[], InputElement> sequence<Literal, InputElement>(parsers)({InputElement*} input)
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
        => forceMany(zeroOrMore<Literal, InputElement>(parser)(str));

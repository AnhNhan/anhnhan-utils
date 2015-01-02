/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.collection {
    LinkedList
}

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
        value secondR = secondP(rest(firstR));
        switch (secondR)
        case (is Ok<SecondLiteral, InputElement>)
        {
            return ok([result(firstR), result(secondR)], rest(secondR));
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
            _input = rest(_result);
            results.add(result(_result));
        }
        else
        {
            return PointOutTheError(input.take(_input.size), rest(_result));
        }
    }

    // TODO: Filter out [] instances coming from skip
    return ok(results.sequence(), _input);
}

shared
ParseResult<Literal[], InputElement> zeroOrMore<Literal, InputElement>(Parser<Literal, InputElement> parser)({InputElement*} str)
        given Literal satisfies Object
{
    variable value _input = str;
    value results = LinkedList<Literal>();

    while (is Ok<Literal, InputElement> _result = parser(_input))
    {
        results.add(result(_result));
        _input = rest(_result);
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

    switch (results)
    // Can this case even apply? Won't [[zeroOrMore]] just return an empty Ok-sequence?
    case (is Error<Literal[], InputElement>)
    {
        // Do any error information get lost?
        // Btw, this has to be explicitly constructed since we can't just return it (incompatible types)
        return JustError(rest(results));
    }
    case (is Ok<Literal[], InputElement>)
    {
        if (nonempty literal = result(results))
        {
            return [literal, rest(results)];
        }
        else
        {
            return JustError(str);
        }
    }
}

/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

"Attempts to apply the two given parsers in order, and returns the first
 success, or returns both failures."
shared
ParseResult<FirstLiteral|SecondLiteral, InputElement> or<FirstLiteral, SecondLiteral, InputElement>(Parser<FirstLiteral, InputElement> firstP, Parser<SecondLiteral, InputElement> secondP, String label = "")({InputElement*} input)
{
    value firstR = firstP(input);
    if (is Ok<FirstLiteral, InputElement> firstR)
    {
        return firstR;
    }

    value secondR = secondP(input);
    if (is Ok<SecondLiteral, InputElement> secondR)
    {
        return secondR;
    }

    return MultitudeOfErrors([firstR, secondR], [*(label.empty then [] else [label])]);
}

"Tries all of the given [[parsers]], one after each other. Returns the result
 of the first successful parser, or a collection of all applied parsers."
shared
ParseResult<Literal, InputElement> anyOf<Literal, InputElement>(Parser<Literal, InputElement>+ parsers)({InputElement*} input)
{
    variable
    Error<Literal, InputElement>[] errors = [];

    for (parser in parsers)
    {
        value _result = parser(input);
        switch (_result)
        case (is Ok<Literal, InputElement>)
        {
            return _result;
        }
        case (is Error<Literal, InputElement>)
        {
            errors = errors.append([_result]);
        }
    }

    assert(nonempty _errors = errors);
    return MultitudeOfErrors(_errors, ["Could not apply any parsers."]);
}

"Applies [[anyOf]] repeatedly, the resulting list of results containing at least
 one element."
shared
ParseResult<[Literal+], InputElement> manyOf<Literal, InputElement>(Parser<Literal, InputElement>+ parsers)({InputElement*} input)
        => oneOrMore(anyOf(*parsers))(input);

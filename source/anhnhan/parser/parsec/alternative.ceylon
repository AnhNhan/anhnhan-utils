/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared
ParseResult<FirstLiteral|SecondLiteral, InputElement> or<FirstLiteral, SecondLiteral, InputElement>(firstP, secondP, label = "")({InputElement*} input)
{
    Parser<FirstLiteral, InputElement> firstP;
    Parser<SecondLiteral, InputElement> secondP;
    String label;

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

    assert(is Error<FirstLiteral, InputElement> firstR);
    assert(is Error<SecondLiteral, InputElement> secondR);

    return MultitudeOfErrors([firstR, secondR], ["Neither of these matched."]);
}

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
    return MultitudeOfErrors(_errors);
}

shared
ParseResult<[Literal+], InputElement> manyOf<Literal, InputElement>(Parser<Literal, InputElement>+ parsers)({InputElement*} input)
        => oneOrMore(anyOf(*parsers))(input);

/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.test {
    assertTrue
}

import de.anhnhan.parser.parsec {
    Parser,
    Ok,
    Error
}

shared
Ok<Literal, InputElement> assertCanParse<Literal, InputElement>(Parser<Literal, InputElement> parser)({InputElement*} input)
{
    value result = parser(input);
    switch (result)
    case (is Ok<Literal, InputElement>)
    {
        return result;
    }
    case (is Error<Literal, InputElement>)
    {
        throw AssertionError("Given parser failed for input <\"``input``\">: resulted in ``result``");
    }
}

shared
Ok<Literal, InputElement> assertCanParseWithNothingLeft<Literal, InputElement>(Parser<Literal, InputElement> parser)({InputElement*} input)
{
    value result = assertCanParse(parser)(input);
    assertTrue(result.rest.empty, "Parser failed to consume the whole input for <\"``input``\">: remaining was <\"``result.rest``\">");
    return result;
}

shared
Error<Literal, InputElement> assertCantParse<Literal, InputElement>(Parser<Literal, InputElement> parser)({InputElement*} input)
{
    value result = parser(input);
    switch (result)
    case (is Ok<Literal, InputElement>)
    {
        throw AssertionError("Given parser did not fail for input <\"``input``\">: resulted in ``result``");
    }
    case (is Error<Literal, InputElement>)
    {
        return result;
    }
}

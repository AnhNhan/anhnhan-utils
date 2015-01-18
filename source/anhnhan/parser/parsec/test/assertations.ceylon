/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import anhnhan.parser.parsec {
    Parser,
    Ok
}

import ceylon.test {
    assertTrue
}

shared
Ok<Literal, InputElement> assertCanParse<Literal, InputElement>(Parser<Literal, InputElement> parser)({InputElement*} input)
{
    value result = parser(input);
    if (is Ok<Literal, InputElement> result)
    {
        return result;
    }
    throw AssertionError("Given parser failed for input <\"``input``\">: resulted in ``result``");
}

shared
Ok<Literal, InputElement> assertCanParseWithNothingLeft<Literal, InputElement>(Parser<Literal, InputElement> parser)({InputElement*} input)
{
    value result = assertCanParse(parser)(input);
    assertTrue(result.rest.empty, "Parser failed to consume the whole input for <\"``input``\">: remaining was <\"``result.rest``\">");
    return result;
}

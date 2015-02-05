/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared
Boolean isApplicable<InputElement>(Parser<Anything, InputElement> parser)({InputElement*} input)
        => parser(input) is Ok<Anything, InputElement>;

shared
Boolean isFullyApplicable<InputElement>(Parser<Anything, InputElement> parser)({InputElement*} input)
{
    value result = parser(input);
    return result is Ok<Anything, InputElement> && result.rest.empty;
}

shared
Boolean notApplicable<InputElement>(Parser<Anything, InputElement> parser)({InputElement*} input)
        => !isApplicable(parser)(input);

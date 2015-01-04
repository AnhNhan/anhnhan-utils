/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared
ParseResult<Literal[], InputElement> lookahead<Literal, InputElement>(Parser<Literal, InputElement> parser)({InputElement*} input)
        given Literal satisfies Object
        => bind<Literal, InputElement, [Literal[], {InputElement*}], Error<Literal[], InputElement>>(
                (_ok) => ok([], input),
                // Converting error since type has to fit
                (error) => toJustError(error)
            )(parser(input));

shared
ParseResult<Literal[], InputElement> negativeLookahead<Literal, InputElement>(Parser<Literal, InputElement> parser)({InputElement*} input)
        given Literal satisfies Object
        => bind<Literal, InputElement, Error<Literal[], InputElement>, [Literal[], {InputElement*}]>(
                (_ok) => JustError(input, ["Negative lookahead did match."]),
                // Converting error since type has to fit
                (error) => ok([], input)
            )(parser(input));

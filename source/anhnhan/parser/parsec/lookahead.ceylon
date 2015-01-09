/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared
ParseResult<[], InputElement> lookahead<Literal, InputElement>(Parser<Literal, InputElement> parser)({InputElement*} input)
        given Literal satisfies Object
        => parser(input).bind(
                (_ok) => ok([], input),
                // Converting error since type has to fit
                (error) => error.toJustError
            );

shared
ParseResult<[], InputElement> negativeLookahead<Literal, InputElement>(Parser<Literal, InputElement> parser)({InputElement*} input)
        given Literal satisfies Object
        => parser(input).bind(
                (_ok) => JustError(input, ["Negative lookahead did match."]),
                // Converting error since type has to fit
                (error) => ok([], input)
            );

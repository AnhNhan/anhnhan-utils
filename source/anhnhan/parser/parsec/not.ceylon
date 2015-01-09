/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared
ParseResult<[], InputElement> not<Literal, InputElement>(Parser<Literal, InputElement> parser)({InputElement*} input)
        given Literal satisfies Object
        => parser(input).bind {
                (ok) => JustError(input);
                (error) => ok([], error.rest);
            };

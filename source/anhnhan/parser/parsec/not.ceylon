/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared
ParseResult<Anything[], InputElement> not<Literal, InputElement>(Parser<Literal, InputElement> parser)({InputElement*} input)
        given Literal satisfies Object
        => bind {
                (Anything ok) => JustError(input);
                (Error<Literal, InputElement> error) => ok([], rest(error));
            } (parser(input));

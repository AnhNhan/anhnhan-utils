/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

""
shared
ParseResult<[], InputElement> skip<Literal, InputElement>(Parser<Literal, InputElement> parser)({InputElement*} input)
        given Literal satisfies Object
        => parser(input).bind {
                (_ok) => ok([], _ok.rest);
                (error) => JustError(input, ["Could not skip."]);
            };

"Aka skippable, or skipIgnore."
shared
ParseResult<[], InputElement> ignore<Literal, InputElement>(Parser<Literal, InputElement> parser)({InputElement*} input)
        given Literal satisfies Object
        => parser(input).bind {
                (_ok) => ok([], _ok.rest);
                (_) => ok([], input);
            };

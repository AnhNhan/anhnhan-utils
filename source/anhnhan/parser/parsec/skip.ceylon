/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

"Applies a [[parser]] on the [[input]] (eventually advancing the input state),
 and discards the parsed result. Effectively 'skips' the result of the parser."
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

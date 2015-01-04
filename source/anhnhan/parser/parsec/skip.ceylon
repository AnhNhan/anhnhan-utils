/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared
ParseResult<Anything[], InputElement> skip<Literal, InputElement>(Parser<Literal, InputElement> parser)({InputElement*} input)
        given Literal satisfies Object
        => bind<Literal, InputElement, [[], {InputElement*}], Error<Anything[], InputElement>> {
                (Ok<Literal, InputElement> _ok) => ok([], rest(_ok));
                (Error<Literal, InputElement> error) => JustError(input, ["Could not skip."]);
            } (parser(input));

"Aka skippable. To skip or not to skip."
shared
ParseResult<Anything[], InputElement> skipIgnore<Literal, InputElement>(Parser<Literal, InputElement> parser)({InputElement*} input)
        given Literal satisfies Object
        => bind<Literal, InputElement, [[], {InputElement*}], [Anything[], {InputElement*}]> {
                (_ok) => ok([], rest(_ok));
                (error) => ok([], input);
            } (parser(input));

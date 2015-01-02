/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared
ParseResult<Return, InputElement> apply<Literal, InputElement, Return>(Parser<Literal, InputElement> parser, Return(Literal) fun)({InputElement*} input)
        given Literal satisfies Object
        given Return satisfies Object
{
    value _result = parser(input);
    switch (_result)
    case (is Ok<Literal, InputElement>)
    {
        return ok(fun(result(_result)), rest(_result));
    }
    case (is Error<Literal, InputElement>)
    {
        return addMessage<Return, InputElement>("Consequence: Did not apply function.")(toJustError(_result));
    }
}

shared
ParseResult<Literal[], InputElement> filterEmpty<Literal, InputElement>(ParseResult<Literal[], InputElement> input)
        given Literal satisfies Object
        => bindOk<Literal[], InputElement, Ok<Literal[], InputElement>> {
                (Ok<Literal[], InputElement> _ok) => ok<Literal[], InputElement>(result(_ok).select((x) => [] != x), rest(_ok));
            } (input);

shared
ParseResult<Anything[], InputElement> not<Literal, InputElement>(Parser<Literal, InputElement> parser)({InputElement*} input)
        given Literal satisfies Object
        => bind {
                (Anything ok) => JustError(input);
                (Error<Literal, InputElement> error) => ok([], rest(error));
            } (parser(input));

shared
ParseResult<Anything[], InputElement> skip<Literal, InputElement>(Parser<Literal, InputElement> parser)({InputElement*} input)
        given Literal satisfies Object
        => bind<Literal, InputElement, [[], {InputElement*}], Error<Anything[], InputElement>> {
                (Ok<Literal, InputElement> _ok) => ok([], rest(_ok));
                (Error<Literal, InputElement> error) => JustError(input, ["Could not skip."]);
            } (parser(input));

shared
ParseResult<Anything[], InputElement> skipIgnore<Literal, InputElement>(Parser<Literal, InputElement> parser)({InputElement*} input)
        given Literal satisfies Object
        => bind<Literal, InputElement, [[], {InputElement*}], Ok<Anything[], InputElement>> {
                (_ok) => ok([], rest(_ok));
                (error) => ok([], input);
            } (parser(input));

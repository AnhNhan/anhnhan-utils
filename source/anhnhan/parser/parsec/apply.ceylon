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
    return applyR(_result, fun);
}

shared
ParseResult<Return, InputElement> applyR<Literal, InputElement, Return>(ParseResult<Literal, InputElement> _result, Return(Literal) fun)
        given Literal satisfies Object
        given Return satisfies Object
{
    switch (_result)
    case (is Ok<Literal, InputElement>)
    {
        return ok(fun(_result.result), _result.rest);
    }
    case (is Error<Literal, InputElement>)
    {
        return _result.toJustError.appendMessage("Consequence: Did not apply function.");
    }
}

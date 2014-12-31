/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared
alias ParseResult<Result, Rest>
        given Result satisfies Object
        given Rest satisfies Object
        => Ok<Result, Rest>
            | Error<Result, Rest>;

// Why can't this be a class alias?
shared
alias Ok<out Result, out Rest> => [Result, Rest];

"Use this function if you want to look cool constructing tuples."
shared
Ok<Result, Rest> ok<Result, Rest>(Result result, Rest rest)
    => [result, rest];
"Use this function if you don't remember at which index the result is located."
shared
Result result<Result, Rest>(Ok<Result, Rest> tup)
    => tup[0];
"Use this function if you don't remember at which index the rest of the input is located."
shared
Rest rest<Result, Rest>(ParseResult<Result, Rest> input)
        given Result satisfies Object
        given Rest satisfies Object
{
    switch (input)
    case (is Ok<Result, Rest>)
    {
        return input[1];
    }
    case (is Error<Result, Rest>)
    {
        return input.parseRest;
    }
}

shared
ReturnOk|ReturnError bind<Result, Rest, ReturnOk, ReturnError>(ok, error)(ParseResult<Result, Rest> input)
        given Result satisfies Object
        given Rest satisfies Object
{
    ReturnOk(Ok<Result, Rest>) ok;
    ReturnError(Error<Result, Rest>) error;

    switch (input)
    case (is Ok<Result, Rest>)
    {
        return ok(input);
    }
    case (is Error<Result, Rest>)
    {
        return error(input);
    }
}

shared
ReturnOk|Error<Result, Rest> bindOk<Result, Rest, ReturnOk>(ReturnOk(Ok<Result, Rest>) ok)(ParseResult<Result, Rest> input)
        given Result satisfies Object
        given Rest satisfies Object
        given ReturnOk satisfies [Object, Rest]
        => bind(ok, identity<Error<Result, Rest>>)(input);

shared
interface Error<out Result, out Rest>
        of ExpectedLiteral<Result, Rest>
            | JustError<Result, Rest>
            | PointOutTheError<Result, Rest>
        given Result satisfies Object
        given Rest satisfies Object
{
    shared formal
    Rest parseRest;

    shared formal
    String[] messages;
}

"Appends the given error message(s) at the end of the error."
shared
Error<Result, Rest> addMessage<Result, Rest>(String[]|String messages)(Error<Result, Rest> error)
        given Result satisfies Object
        given Rest satisfies Object
{
    String[] _messages;
    switch (messages)
    case (is String)
    {
        _messages = [messages];
    }
    case (is String[])
    {
        _messages = messages;
    }
    value newMessages = error.messages.append(_messages);
    value parseRest = error.parseRest;

    switch (error)
    case (is JustError<Result, Rest>)
    {
        return JustError(parseRest, newMessages);
    }
    case (is ExpectedLiteral<Result, Rest>)
    {
        return ExpectedLiteral<Result, Rest>(error.expected, error.instead, parseRest, newMessages);
    }
    case (is PointOutTheError<Result, Rest>)
    {
        return PointOutTheError(error.beforeError, parseRest, newMessages);
    }
}

shared final
class JustError<out Result, out Rest>(parseRest, messages = [])
        extends Object()
        satisfies Error<Result, Rest>
        given Result satisfies Object
        given Rest satisfies Object
{
    shared actual
    Rest parseRest;
    shared actual Boolean equals(Object that) {
        if (is JustError<Result, Rest> that) {
            return parseRest==that.parseRest;
        }
        else {
            return false;
        }
    }

    shared actual Integer hash {
        variable value hash = 1;
        hash = 31*hash + parseRest.hash;
        return hash;
    }

    shared actual String[] messages;
}

shared final
class ExpectedLiteral<out Result, out Rest>(Result|{Result*} _expected, instead, parseRest, messages = [])
        extends Object()
        satisfies Error<Result, Rest>
        given Result satisfies Object
        given Rest satisfies Object
{
    shared
    {Result*} expected;

    if (is {Result*} _expected)
    {
        expected = _expected;
    }
    else
    {
        "Insufficient type narrowing."
        assert(is Result _expected);
        expected = [_expected];
    }

    shared
    Result? instead;

    shared actual
    Rest parseRest;

    string = "ExpectedLiteral(expected = '``expected``', instead = '``instead else "<null>"``', rest = '``parseRest``')";

    shared actual Boolean equals(Object that) {
        if (is ExpectedLiteral<Result, Rest> that) {
            // Skipping instead is sensible, considering it is only for helping
            return expected==that.expected &&
                parseRest==that.parseRest;
        }
        else {
            return false;
        }
    }

    shared actual Integer hash {
        variable value hash = 1;
        hash = 31*hash + expected.hash;
        hash = 31*hash + parseRest.hash;
        if (exists instead)
        {
            hash = 31*hash + instead.hash;
        }
        return hash;
    }

    shared actual String[] messages;
}

shared final
class PointOutTheError<out Result, out Rest>(beforeError, parseRest, messages = [])
        extends Object()
        satisfies Error<Result, Rest>
        given Result satisfies Object
        given Rest satisfies Object
{
    shared
    Rest beforeError;

    shared actual
    Rest parseRest;

    shared actual Boolean equals(Object that) {
        if (is PointOutTheError<Result, Rest> that) {
            return beforeError==that.beforeError &&
                parseRest==that.parseRest;
        }
        else {
            return false;
        }
    }

    shared actual Integer hash {
        variable value hash = 1;
        hash = 31*hash + beforeError.hash;
        hash = 31*hash + parseRest.hash;
        return hash;
    }

    shared actual String[] messages;
}

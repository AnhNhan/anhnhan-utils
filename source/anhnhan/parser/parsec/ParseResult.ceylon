/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared
alias ParseResult<Result, InputElement>
        given Result satisfies Object
        => Ok<Result, InputElement>
            | Error<Result, InputElement>;

// Why can't this be a class alias?
shared
alias Ok<out Result, out InputElement>
        => [Result, {InputElement*}];

shared
interface Parser<out Result, InputElement>
        given Result satisfies Object
        => ParseResult<Result, InputElement>({InputElement*});

"Use this function if you want to look cool constructing tuples."
shared
Ok<Result, InputElement> ok<Result, InputElement>(Result result, {InputElement*} rest)
    => [result, rest];
"Use this function if you don't remember at which index the result is located."
shared
Result result<Result>(Ok<Result, Anything> tup)
    => tup[0];
"Use this function if you don't remember at which index the rest of the input is located."
shared
{InputElement*} rest<InputElement>(ParseResult<Object, InputElement> input)
{
    switch (input)
    case (is Ok<Object, InputElement>)
    {
        return input[1];
    }
    case (is Error<Object, InputElement>)
    {
        return input.parseRest;
    }
}

shared
ReturnOk|ReturnError bind<Result, InputElement, ReturnOk, ReturnError>(ok, error)(ParseResult<Result, InputElement> input)
        given Result satisfies Object
{
    ReturnOk(Ok<Result, InputElement>) ok;
    ReturnError(Error<Result, InputElement>) error;

    switch (input)
    case (is Ok<Result, InputElement>)
    {
        return ok(input);
    }
    case (is Error<Result, InputElement>)
    {
        return error(input);
    }
}

shared
ReturnOk|Error<Result, InputElement> bindOk<Result, InputElement, ReturnOk>(ReturnOk(Ok<Result, InputElement>) ok)(ParseResult<Result, InputElement> input)
        given Result satisfies Object
        given ReturnOk satisfies [Object, {InputElement*}]
        => bind<Result, InputElement, ReturnOk, Error<Result, InputElement>>(ok, identity<Error<Result, InputElement>>)(input);

shared
Boolean isEmptyResult<Result, InputElement>(Ok<Result, InputElement> input)
        given Result satisfies Object
{
    value _result = result(input);
    if (is Anything[] _result)
    {
        return _result == [];
    }
    else
    {
        return false;
    }
}

shared
interface Error<out Result, out InputElement>
        of ExpectedLiteral<Result, InputElement>
            | JustError<Result, InputElement>
            | PointOutTheError<Result, InputElement>
            | MultitudeOfErrors<Result, InputElement>
        given Result satisfies Object
{
    shared formal
    {InputElement*} parseRest;

    shared formal
    String[] messages;
}

"Appends the given error message(s) at the end of the error."
shared
Error<Result, InputElement> addMessage<Result, InputElement>(String[]|String messages)(Error<Result, InputElement> error)
        given Result satisfies Object
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
    case (is JustError<Result, InputElement>)
    {
        return JustError(parseRest, newMessages);
    }
    case (is ExpectedLiteral<Result, InputElement>)
    {
        return ExpectedLiteral<Result, InputElement>(error.expected, error.instead, parseRest, newMessages);
    }
    case (is PointOutTheError<Result, InputElement>)
    {
        return PointOutTheError(error.beforeError, parseRest, newMessages);
    }
    case (is MultitudeOfErrors<Result, InputElement>)
    {
        return MultitudeOfErrors(error.errors, newMessages);
    }
}

shared
JustError<Nothing, InputElement> toJustError<InputElement>(Error<Object, InputElement> error)
        => JustError(error.parseRest, error.messages);

shared final
class JustError<out Result, out InputElement>(parseRest, messages = [])
        extends Object()
        satisfies Error<Result, InputElement>
        given Result satisfies Object
{
    shared actual
    {InputElement*} parseRest;
    shared actual Boolean equals(Object that) {
        if (is JustError<Result, InputElement> that) {
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
class ExpectedLiteral<out Result, out InputElement>(Result|{Result*} _expected, instead, parseRest, messages = [])
        extends Object()
        satisfies Error<Result, InputElement>
        given Result satisfies Object
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
    {InputElement*} parseRest;

    string = "ExpectedLiteral(expected = '``expected``', instead = '``instead else "<null>"``', rest = '``parseRest``')";

    shared actual Boolean equals(Object that) {
        if (is ExpectedLiteral<Result, InputElement> that) {
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
class PointOutTheError<out Result, out InputElement>(beforeError, parseRest, messages = [])
        extends Object()
        satisfies Error<Result, InputElement>
        given Result satisfies Object
{
    shared
    {InputElement*} beforeError;

    shared actual
    {InputElement*} parseRest;

    shared actual Boolean equals(Object that) {
        if (is PointOutTheError<Result, InputElement> that) {
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

shared final
class MultitudeOfErrors<out Result, out InputElement>(errors, String[] _messages = [])
        extends Object()
        satisfies Error<Result, InputElement>
        given Result satisfies Object
{
    shared
    [Error<Result, InputElement>+] errors;

    shared actual String[] messages
            = errors*.messages.append([_messages]).reduce(uncurry(Sequential<String>.append<String>));

    shared actual {InputElement*} parseRest = errors.max((Error<Result,InputElement> x, Error<Result,InputElement> y) => x.messages.size <=> y.messages.size).parseRest;

    shared actual Boolean equals(Object that) {
        if (is MultitudeOfErrors<Result, InputElement> that) {
            return errors==that.errors;
        }
        else {
            return false;
        }
    }

    shared actual Integer hash {
        variable value hash = 1;
        hash = 31*hash + errors.hash;
        return hash;
    }
}

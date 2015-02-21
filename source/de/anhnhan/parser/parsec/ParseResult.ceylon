/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

"A parser parses a list of elements and yields a result."
shared
interface Parser<out Result, InputElement>
        => ParseResult<Result, InputElement>({InputElement*});

"A ParseResult represents the result of a parse operation. There are two defined
 states, [[Ok]] and [[Error]], respectively representing successful / failed
 parse attempts.

 A ParseResult value contains the resulting parser state on the input stream as
 a stream of the remaining elements.

 It also contains a few useful operations, for example the [[bind]] method to
 bind transformations on the resulting result / state."
shared
interface ParseResult<out Result, out InputElement>
        of Ok<Result, InputElement>
            | Error<Result, InputElement>
{
    "The parser state after applying the parse operation."
    shared formal
    {InputElement*} rest;

    shared default
    ReturnOk|ReturnError bind<ReturnOk, ReturnError>(onOk, onError)
    {
        ReturnOk(Ok<Result, InputElement>) onOk;
        ReturnError(Error<Result, InputElement>) onError;

        value self = this;
        switch (self)
        case (is Ok<Result, InputElement>)
        {
            return onOk(self);
        }
        case (is Error<Result, InputElement>)
        {
            return onError(self);
        }
    }

    shared default
    ReturnOk|Error<Result, InputElement> bindOk<ReturnOk>(ReturnOk(Ok<Result, InputElement>) onOk)
            => bind<ReturnOk, Error<Result, InputElement>>(onOk, identity<Error<Result, InputElement>>);

    shared default
    Ok<Result, InputElement>|ReturnError bindError<ReturnError>(ReturnError(Error<Result, InputElement>) onError)
            => bind<Ok<Result, InputElement>, ReturnError>(identity<Ok<Result, InputElement>>, onError);

    shared default
    ParseResult<Result, InputElement> label(String label)
            => bind(identity<Ok<Result, InputElement>>, (error) => error.appendMessage(label));

    shared default
    ParseResult<Result, InputElement> expectedLabel(String expected)
            => label("Expected: ``expected``");

    shared default
    ParseResult<FunResult, InputElement> applyOnResult<FunResult>(FunResult transform(Result element))
            => applyR(this, transform);

    shared default
    Boolean isSuccessful
            => this is Ok<Result, InputElement>;
}

"`Ok` represents a successful parse operation and contains its result."
shared
interface Ok<out Result, out InputElement>
        satisfies ParseResult<Result, InputElement>
{
    "The result of the parse operation."
    shared formal
    Result result;

    string => "Ok(``result else "<end of input>"``, ``rest``)";

    shared actual
    Boolean equals(Object that)
    {
        if (is OkImpl<Anything, Anything> that)
        {
            Boolean result_same;

            if (exists _result = result)
            {
                if (exists t_result = that.result)
                {
                    result_same = _result == t_result;
                }
                else
                {
                    result_same = false;
                }
            }
            else
            {
                if (exists t_result = that.result)
                {
                    result_same = false;
                }
                else
                {
                    result_same = true;
                }
            }

            return result_same &&
                rest==that.rest;
        }
        else
        {
            return false;
        }
    }

    shared actual
    Integer hash
    {
        variable value hash = 1;
        hash = 31*hash + (result else 1).hash;
        hash = 31*hash + rest.hash;
        return hash;
    }
}

final
class OkImpl<out Result, out InputElement>(result, rest)
        extends Object()
        satisfies Ok<Result, InputElement>
{
    shared actual
    Result result;

    shared actual
    {InputElement*} rest;
}

final
class StringOk<out Result>(result, rest)
        extends Object()
        satisfies Ok<Result, Character>
        {
    shared actual
    Result result;

    shared actual
    {Character*} rest;
}

shared
Ok<Result, InputElement> ok<out Result, out InputElement>(Result result, {InputElement*} rest)
        => OkImpl(result, rest);

shared
Ok<Result, Character> strOk<out Result>(Result result, {Character*} rest)
        => StringOk(result, rest);

"Returns a parser that always returns [[result]], no matter the input."
shared
Result({InputElement*}) identityParser<Literal, InputElement, Result = ParseResult<Literal, InputElement>>(Result result)
        given Result satisfies ParseResult<Literal, InputElement>
        => ({InputElement*} _) => result;

"Represents a failed parse attempt. It contains the parser state ([[rest]]) at
 the point of failure, and optionally a list of [[messages]] to help in
 understanding the cause of failure.

 An error generally is specific to a class of results (see [[Result]]
 parameter), where implementations are free to provide additional information to
 help debug and understand the cause of failure (e.g. [[ExpectedLiteral]])."
shared
interface Error<out Result, out InputElement>
        of ExpectedLiteral<Result, InputElement>
            | JustError<Result, InputElement>
            | PointOutTheError<Result, InputElement>
            | MultitudeOfErrors<Result, InputElement>
        satisfies ParseResult<Result, InputElement>
{
    shared formal
    String[] messages;

    "Appends the given error message(s) at the end of the error."
    shared default
    Error<Result, InputElement> appendMessage(String[]|String messages)
    {
        value error = this;
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
        value parseRest = error.rest;

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

    // TODO: Instead of destroying the old value, consider boxing it
    shared default
    Error<Nothing, InputElement> toJustError
            => JustError(this.rest, this.messages);
}

"General purpose error, fitting everywhere (since it usually is resolved as
 `JustError<Nothing, InputElement>`)."
shared final
class JustError<out Result, out InputElement>(rest, messages = [])
        extends Object()
        satisfies Error<Result, InputElement>
{
    shared actual
    {InputElement*} rest;

    shared actual
    String[] messages;

    string => "JustError(parseRest='``rest``', messages=``messages``)";

    shared actual
    Boolean equals(Object that)
    {
        if (is JustError<Result, InputElement> that)
        {
            return rest==that.rest;
        }
        else
        {
            return false;
        }
    }

    shared actual
    Integer hash
    {
        variable value hash = 1;
        hash = 31*hash + rest.hash;
        return hash;
    }
}

shared final
class ExpectedLiteral<out Result, out InputElement>(Result|{Result*} _expected, instead, rest, messages = [])
        extends Object()
        satisfies Error<Result, InputElement>
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
    {InputElement*} rest;

    shared actual
    String[] messages;

    string = "ExpectedLiteral(expected = '``expected``', instead = '``instead else "<null>"``', rest = '``rest``', messages=``messages``)";

    shared actual
    Boolean equals(Object that)
    {
        if (is ExpectedLiteral<Result, InputElement> that)
        {
            // Skipping instead is sensible, considering it is only for helping
            return expected==that.expected &&
                rest==that.rest;
        }
        else
        {
            return false;
        }
    }

    shared actual
    Integer hash
    {
        variable value hash = 1;
        hash = 31*hash + expected.hash;
        hash = 31*hash + rest.hash;
        if (exists instead)
        {
            hash = 31*hash + instead.hash;
        }
        return hash;
    }
}

shared final
class PointOutTheError<out Result, out InputElement>(beforeError, rest, messages = [])
        extends Object()
        satisfies Error<Result, InputElement>
{
    shared
    {InputElement*} beforeError;

    shared actual
    {InputElement*} rest;

    shared actual
    Boolean equals(Object that)
    {
        if (is PointOutTheError<Result, InputElement> that)
        {
            return beforeError==that.beforeError &&
                rest==that.rest;
        }
        else
        {
            return false;
        }
    }

    shared actual
    Integer hash
    {
        variable value hash = 1;
        hash = 31*hash + beforeError.hash;
        hash = 31*hash + rest.hash;
        return hash;
    }

    shared actual
    String[] messages;

    string = "PointOutTheError(beforeError=``beforeError``, parseRest=``rest``, messages=``messages``)";
}

shared final
class MultitudeOfErrors<out Result, out InputElement>(errors, String[] _messages = [])
        extends Object()
        satisfies Error<Result, InputElement>
{
    shared
    [Error<Anything, InputElement>+] errors;

    shared actual
    String[] messages
            = errors*.messages
                .append([_messages])
                .reduce(uncurry(Sequential<String>.append<String>));

    shared actual
    {InputElement*} rest
            = errors.max((x, y) => x.messages.size <=> y.messages.size).rest;

    toJustError => MultitudeOfErrors(errors, _messages);

    string => "MultitudeOfErrors(``errors``, ``_messages``)";

    shared actual
    Boolean equals(Object that)
    {
        if (is MultitudeOfErrors<Result, InputElement> that)
        {
            return errors==that.errors;
        }
        else
        {
            return false;
        }
    }

    shared actual
    Integer hash
    {
        variable value hash = 1;
        hash = 31*hash + errors.hash;
        return hash;
    }
}

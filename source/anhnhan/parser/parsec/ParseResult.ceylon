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

shared
Ok<Result, Rest> ok<Result, Rest>(Result result, Rest rest)
    => [result, rest];
shared
Result result<Result, Rest>(Ok<Result, Rest> tup)
    => tup[0];
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
interface Error<out Result, out Rest>
        of ExpectedLiteral<Result, Rest>
            | JustError<Result, Rest>
            | PointOutTheError<Result, Rest>
        given Result satisfies Object
        given Rest satisfies Object
{
    shared formal
    Rest parseRest;
}

shared final
class JustError<out Result, out Rest>(parseRest)
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
}

shared final
class ExpectedLiteral<out Result, out Rest>(expected, instead, parseRest)
        extends Object()
        satisfies Error<Result, Rest>
        given Result satisfies Object
        given Rest satisfies Object
{
    shared
    Result expected;
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
}

shared final
class PointOutTheError<out Result, out Rest>(beforeError, parseRest)
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
}

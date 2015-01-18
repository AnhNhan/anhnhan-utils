/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

"Applies two parsers, and returns the first / left result (and parser state).

 Useful when you want to apply discards / lookaheads."
shared
ParseResult<Literal, InputElement> left<Literal, InputElement>(Parser<Literal, InputElement> leftP,  Parser<Anything, InputElement> rightP)({InputElement*} input)
        => leftP(input).bind
        {
            (_ok) => rightP(_ok.rest).bind
            {
                (_okRight) => ok(_ok.result, _ok.rest);
                (error) => error.toJustError;
            };
            (error) => error.toJustError;
        };

"Applies two parsers, and returns the second / right result (and parser state).

 Useful when you want to apply discards / lookbehinds."
shared
ParseResult<Literal, InputElement> right<Literal, InputElement>(Parser<Anything, InputElement> leftP,  Parser<Literal, InputElement> rightP)({InputElement*} input)
        => apply(and(leftP, rightP), ([Anything, Literal] tup) => tup[1])(input);

"Given two parsers, it will apply both, returning the result of the left parser,
 and the resulting state after applying the right parser.

 This is usefule if you want to skip the right parser, but retain its state.

 Note that the right parser still is required to succeed."
shared
ParseResult<Literal, InputElement> leftRrightS<Literal, InputElement>(Parser<Literal, InputElement> leftP, Parser<Anything, InputElement> rightP)({InputElement*} input)
        => leftP(input).bind
        {
            (_ok) => rightP(_ok.rest).bind
            {
                (_okRight) => ok(_ok.result, _okRight.rest);
                (error) => error.toJustError;
            };
            (error) => error.toJustError;
        };

/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

"Applies two parsers, and returns the first / left result (and parser state).

 Useful when you want to apply discards / lookaheads."
shared
ParseResult<Literal, InputElement> left<Literal, InputElement>(Parser<Literal, InputElement> leftP,  Parser<Anything, InputElement>rightP)({InputElement*} input)
        => apply(and(leftP, rightP), ([Literal, Anything] tup) => tup[0])(input);

"Applies two parsers, and returns the second / right result (and parser state).

 Useful when you want to apply discards / lookbehinds."
shared
ParseResult<Literal, InputElement> right<Literal, InputElement>(Parser<Anything, InputElement> leftP,  Parser<Literal, InputElement>rightP)({InputElement*} input)
        => apply(and(leftP, rightP), ([Anything, Literal] tup) => tup[1])(input);

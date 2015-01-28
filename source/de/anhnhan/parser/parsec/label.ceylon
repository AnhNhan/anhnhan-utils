/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

"Attaches a label / message to the parser that is displayed on its error."
shared
ParseResult<Literal, InputElement> label<Literal, InputElement>(Parser<Literal, InputElement> parser, String label)({InputElement*} input)
        => parser(input).label(label);

"Attaches a label / message to the parser that is displayed on its error."
shared
ParseResult<Literal, InputElement> expected<Literal, InputElement>(Parser<Literal, InputElement> parser, String label)({InputElement*} input)
        => parser(input).expectedLabel(label);

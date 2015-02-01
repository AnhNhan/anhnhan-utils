/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared
ParseResult<Returns, InputElement> tryAndAct<Literals, Returns, InputElement>(parsersAndActions)({InputElement*} input)
{
    // TODO: Preserve each type-pair somehow.
    <Parser<Literals, InputElement>->Returns(Literals)>+ parsersAndActions;

    for (parser->action in parsersAndActions)
    {
        if (is Ok<Literals, InputElement> result = parser(input))
        {
            return result.applyOnResult(action);
        }
    }

    return JustError(input, ["None of the parsers we tried out matched."]);
}

shared
ParseResult<Literal?, InputElement> tryWhen<Literal, InputElement>(Parser<Anything, InputElement> matchP, Parser<Literal, InputElement> mainP)({InputElement*} input)
        => matchP(input).bind
        {
            (matchR) => mainP(matchR.rest);
            (_) => ok(null, input);
        };

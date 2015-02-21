/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.test {
    test
}

"Tests whether the given parser is applicable on the current parser state.
 Returns an empty result and retains the parser state."
shared
ParseResult<[], InputElement> nextIs<Literal, InputElement>(Parser<Literal, InputElement> parser)({InputElement*} input)
        given Literal satisfies Object
        => parser(input).bind(
                (_ok) => ok([], input),
                // Converting error since type has to fit
                (error) => error.toJustError.appendMessage("Lookahead failed.")
            );

// Same as `not`?
shared
ParseResult<[], InputElement> nextIsnt<Literal, InputElement>(Parser<Literal, InputElement> parser)({InputElement*} input)
        given Literal satisfies Object
        => parser(input).bind(
                (_ok) => JustError(input, ["Negative lookahead did match."]),
                // Converting error since type has to fit
                (error) => ok([], input)
            );

"Attempts a lookahead, and applies the parser if it succeeds. Returns null in
 case the lookahead did not match."
see(`function lookahead`)
shared
ParseResult<Literal?, InputElement> optionalLookahead<Literal, InputElement>(Parser<Anything, InputElement> matchP, Parser<Literal, InputElement> mainP)({InputElement*} input)
        => matchP(input).bind
        {
            (matchR) => mainP(matchR.rest);
            (_) => ok(null, input);
        };

shared
interface LookaheadHandler<out Literal, InputElement>
{
    shared formal
    Parser<Anything, InputElement>|Boolean({InputElement*}) lookaheadMatcher;

    "The parser to be applied when the lookahead matches."
    shared formal
    Parser<Literal, InputElement> parser;

    shared
    Boolean applicable({InputElement*} input)
    {
        // Switch-case is ambiguous?
        value matcher = lookaheadMatcher;
        if (is Boolean({InputElement*}) matcher)
        {
            return matcher(input);
        }
        else if (is Parser<Anything, InputElement> matcher)
        {
            return isApplicable(matcher)(input);
        }
        else
        {
            assert (false);
        }
    }
}

shared
LookaheadHandler<Literal, InputElement> lookaheadCase<Literal, InputElement>(Parser<Anything, InputElement>|<Boolean({InputElement*})> matcher, Parser<Literal, InputElement> _parser)
{
    object lookaheadCase
            satisfies LookaheadHandler<Literal, InputElement>
    {
        lookaheadMatcher = matcher;
        parser = _parser;
    }
    return lookaheadCase;
}

shared
LookaheadHandler<Literal, InputElement> lookaheadCaseSingleLiteral<Literal, InputElement>(Boolean(InputElement) matcher, Parser<Literal, InputElement> _parser)
        => lookaheadCase<Literal, InputElement>(satisfy(matcher), _parser);

"Tries out a bunch of lookahead matches, and returns the result for the first
 match we encounter. Lookahead cases are tried out in the order of the
 arguments."
see(`function optionalLookahead`)
shared
ParseResult<Literals, InputElement> lookahead<Literals, InputElement>(LookaheadHandler<Literals, InputElement>+ handlers)({InputElement*} input)
        => { for (handler in handlers) if (handler.applicable(input)) handler.parser(input) }.first else JustError(input, ["No lookahead match found."]);

test
void testLookahead()
{
    value str1 = "foo";
    value str2 = "bar";
    value str3 = "baz";

    value parser1 = lookahead(
        lookaheadCase(literal('f'), literals("foo")),
        lookaheadCase(({Character*} str) => str.first exists then (str.first else nothing) in "fb" else false, literals("bar"))
    );

    value result1 = parser1(str1);
    value result2 = parser1(str2);
    value result3 = parser1(str3);

    assert (is Ok<[Character+], Character> result1);
    assert (is Ok<[Character+], Character> result2);
    assert (is Error<[Character+], Character> result3);
}

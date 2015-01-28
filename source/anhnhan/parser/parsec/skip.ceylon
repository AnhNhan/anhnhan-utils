/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import anhnhan.parser.parsec.string {
    letter
}

import ceylon.test {
    assertEquals,
    test
}

"Applies a [[parser]] on the [[input]] (eventually advancing the input state),
 and discards the parsed result. Effectively 'skips' the result of the parser.

 The [[parser]] *has* to apply, and you will end up with an instance of [[Empty]]
 in your token stream."
shared
ParseResult<[], InputElement> skip<InputElement>(Parser<Anything, InputElement> parser)({InputElement*} input)
        => parser(input).bind {
                (_ok) => ok([], _ok.rest);
                (error) => JustError(input, ["Could not skip."]);
            };

"Aka skippable, or skipIgnore. Note that you will end up with an instance of
 [[Empty]] in your token stream."
shared
ParseResult<[], InputElement> ignore<InputElement>(Parser<Anything, InputElement> parser)({InputElement*} input)
        => parser(input).bind {
                (_ok) => ok([], _ok.rest);
                (_) => ok([], input);
            };

shared
Parser<Literal, InputElement> ignoreSurrounding<Literal, InputElement>(Parser<Anything, InputElement> ignore)(Parser<Literal, InputElement> parser)
        => leftRrightS(right(ignore, parser), ignore);

test
void testIgnoreSurrounding()
{
    value str = "***foo***";

    value parse = ignoreSurrounding<[Character+], Character>(ignore(manySatisfy<Character>('*'.equals)))(manyOf(letter));
    value result = parse(str);
    assert(is Ok<[Character+], Character> result);
    assertEquals(result.result, ['f', 'o', 'o']);
    assertEquals(result.rest, "");
}

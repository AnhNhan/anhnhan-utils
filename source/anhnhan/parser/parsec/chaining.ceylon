/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.collection {
    LinkedList
}
import ceylon.test {
    test,
    assertEquals
}

shared
ParseResult<[FirstLiteral, SecondLiteral], InputElement> and<FirstLiteral, SecondLiteral, InputElement>(firstP, secondP)({InputElement*} input)
{
    Parser<FirstLiteral, InputElement> firstP;
    Parser<SecondLiteral, InputElement> secondP;

    return firstP(input).bind {
        (firstR) => secondP(firstR.rest).bind {
            (secondR) => ok([firstR.result, secondR.result], secondR.rest);
            (error) => error.toJustError;
        };
        (error) => error.toJustError;
    };
}

shared
ParseResult<[Literal+], InputElement> sequence<Literal, InputElement>(parsers)({InputElement*} input)
{
    Parser<Literal, InputElement>+ parsers;
    variable value _input = input;
    value results = LinkedList<Literal>();

    for (parser in parsers)
    {
        value _result = parser(_input);
        if (is Ok<Literal, InputElement> _result)
        {
            _input = _result.rest;
            results.add(_result.result);
        }
        else
        {
            return PointOutTheError(input.take(_result.rest.size), _result.rest);
        }
    }

    // TODO: Filter out [] instances coming from skip
    "We have multiple parsers - so we have multiple elements.
     Of course this will change once we do filter elements from
     [[skip]], [[ignore]] etc."
    assert(nonempty seq = results.sequence());
    return ok(seq, _input);
}

shared
Ok<Literal[], InputElement> zeroOrMore<Literal, InputElement>(Parser<Literal, InputElement> parser)({InputElement*} str)
{
    variable value _input = str;
    value results = LinkedList<Literal>();

    while (is Ok<Literal, InputElement> _result = parser(_input))
    {
        results.add(_result.result);
        _input = _result.rest;
    }

    // TODO: Filter out [] instances coming from skip
    return ok(results.sequence(), _input);
}

shared
Ok<Literal[], InputElement> zeroOrMoreInterleaved<Literal, InputElement>(Parser<Anything, InputElement> interleave)(Parser<Literal, InputElement> parser)({InputElement*} str)
        => zeroOrMore(right(interleave, parser))(str);

// Success may be skewed due to possibly containing empty results.
shared
ParseResult<[Literal+], InputElement> oneOrMore<Literal, InputElement>(Parser<Literal, InputElement> parser)({InputElement*} str)
        => forceMany(zeroOrMore<Literal, InputElement>(parser)(str));

shared
ParseResult<[Literal+], InputElement> oneOrMoreInterleaved<Literal, InputElement>(Parser<Anything, InputElement> interleave)(Parser<Literal, InputElement> parser)({InputElement*} str)
        => oneOrMore(right(interleave, parser))(str);

shared
ParseResult<[Literal+], InputElement> separatedBy<Literal, InputElement>(Parser<Literal, InputElement> contentP, Parser<Anything, InputElement> separatorP)({InputElement*} str)
{
    value exceptLast = zeroOrMore(leftRrightS(contentP, separatorP))(str);
    return exceptLast.bind
    {
        onOk = (_ok)
        {
            value last = contentP(_ok.rest);
            if (is Ok<Literal, InputElement> last, nonempty okResult = _ok.result.append([last.result]))
            {
                return ok(okResult, last.rest);
            }
            else if (nonempty okResult = _ok.result)
            {
                // Notice: This disregards trailing separators
                return ok(okResult, _ok.rest);
            }
            else
            {
                return JustError(_ok.rest);
            }
        };
        (error) => error.toJustError;
    };
}

test
void testSeparatedBy()
{
    value str1 = "foo";
    value str2 = "foo,foo,foo,";

    value parse = separatedBy(manySatisfy((Character char) => char != ','), literal(','));

    value result1 = parse(str1);
    value result2 = parse(str2);

    assert(is Ok<[[Character+]+], Character> result1);
    assert(is Ok<[[Character+]+], Character> result2);

    assertEquals(result1.result, [['f', 'o', 'o']]);
    assertEquals(result1.rest, "");
    // Note: Since [[contentP]] is a [Literal+] parser, we are not parsing the 'empty' column after the last comma
    assertEquals(result2.result, [['f', 'o', 'o'], ['f', 'o', 'o'], ['f', 'o', 'o']]);
    // Bug? We are disregarding trailing separators
    assertEquals(result2.rest, "");
}

"Applies [[innerP]] repeatedly until [[untilP]] can be successfully applied.
 The result is then returned."
shared
ParseResult<Literal[], InputElement> until<Literal, InputElement>(Parser<Anything, InputElement> untilP, Parser<Literal, InputElement> innerP)({InputElement*} input)
{
    value list = LinkedList<Literal>();
    variable
    value _input = input;
    while (is Error<Anything, InputElement> untilR = untilP(_input))
    {
        value result = innerP(_input);
        switch (result)
        case (is Ok<Literal, InputElement>)
        {
            list.add(result.result);
            _input = result.rest;
        }
        case (is Error<Literal, InputElement>)
        {
            return result.toJustError.appendMessage("Failed 'until' parse. Did not reach ending delimeter.");
        }
    }

    value seq = list.sequence();
    return ok(seq, _input);
}

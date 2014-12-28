/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import anhnhan.parser.combinator {
    Ok
}

import ceylon.collection {
    LinkedList
}

shared
ParseResult<[Atom, Atom], {Atom*}> and<Atom>(firstParser, secondParser)({Atom*} str)
        given Atom satisfies Object
{
    ParseResult<Atom, {Atom*}>({Atom*}) firstParser;
    ParseResult<Atom, {Atom*}>({Atom*}) secondParser;

    value first = firstParser(str);
    if (is Ok<Atom, {Atom*}> first)
    {
        value second = secondParser(rest(first));
        if (is Ok<Atom, {Atom*}> second)
        {
            return ok([result(first), result(second)], rest(second));
        }
        return PointOutTheError(rest(first), rest(second));
    }
    return JustError(rest(first));
}

shared
ParseResult<Atom[], {Atom*}> sequence<Atom>(ParseResult<Atom, {Atom*}>({Atom*})+ parsers)({Atom*} str)
        given Atom satisfies Object
{
    variable value _input = str;
    value results = LinkedList<Atom>();

    for (parser in parsers)
    {
        value _result = parser(_input);
        if (is Ok<Atom, {Atom*}> _result)
        {
            _input = rest(_result);
            results.add(result(_result));
        }
        else
        {
            return PointOutTheError(str.take(_input.size), rest(_result));
        }
    }

    // TODO: Filter out [] instances coming from skip
    return ok(results.sequence(), _input);
}

shared
ParseResult<Atom[], {Atom*}> zeroOrMore<Atom>(ParseResult<Atom, {Atom*}>({Atom*}) parser)({Atom*} str)
        given Atom satisfies Object
{
    variable value _input = str;
    value results = LinkedList<Atom>();

    while (is Ok<Atom, {Atom*}> _result = parser(_input))
    {
        results.add(result(_result));
        _input = rest(_result);
    }

    // TODO: Filter out [] instances coming from skip
    return ok(results.sequence(), _input);
}

shared
ParseResult<[Atom+], {Atom*}> oneOrMore<Atom>(ParseResult<Atom, {Atom*}>({Atom*}) parser)({Atom*} str)
        given Atom satisfies Object
{
    value results = zeroOrMore<Atom>(parser)(str);

    switch (results)
    // Can this case even apply? Won't [[zeroOrMore]] just return an empty Ok-sequence?
    case (is Error<Atom[], {Atom*}>)
    {
        // Do any error information get lost?
        // Btw, this has to be explicitly constructed since we can't just return it (incompatible types)
        return JustError(rest(results));
    }
    case (is Ok<Atom[], {Atom*}>)
    {
        if (nonempty literal = result(results))
        {
            return [literal, rest(results)];
        }
        else
        {
            return JustError(str);
        }
    }
}

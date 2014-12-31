/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared
ParseResult<Anything[], {Atom*}> skip<Atom>(ParseResult<Atom, {Atom*}>({Atom*}) parser)({Atom*} str)
        given Atom satisfies Object
{
    value result = parser(str);
    switch (result)
    case (is Ok<Atom, {Atom*}>)
    {
        return [[], rest(result)];
    }
    else
    {
        return JustError(str);
    }
}

shared
ParseResult<Anything[], {Atom*}> skip2<Atom>(ParseResult<Atom, {Atom*}>({Atom*}) parser)({Atom*} str)
        given Atom satisfies Object
        => bind {
                (Ok<Atom, {Atom*}> val) => ok([], rest(val));
                (Error<Atom, {Atom*}> error) => JustError(rest(error));
            } (parser(str));

shared
Ok<Atom[], {Atom*}> ignoreSkip<Atom>(ParseResult<Atom, {Atom*}>({Atom*}) parser)({Atom*} str)
        given Atom satisfies Object
        => bind {
                (Ok<Atom, {Atom*}> val) => ok([], rest(val));
                (Error<Atom, {Atom*}> error) => ok([], str);
            } (parser(str));

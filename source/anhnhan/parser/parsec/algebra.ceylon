/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

// Parser algebra (like, negating stuff)

shared
ParseResult<Anything[], {Atom*}> not<Atom, ReturnAtom>(ParseResult<ReturnAtom, {Atom*}>({Atom*}) parser)({Atom*} str)
        given Atom satisfies Object
        given ReturnAtom satisfies Object
{
    value result = parser(str);
    switch (result)
    case (is Ok<ReturnAtom, {Atom*}>)
    {
        return JustError(str);
    }
    case (is Error<ReturnAtom, {Atom*}>)
    {
        return ok([], str);
    }
}

shared
ParseResult<Anything[], {Atom*}> not2<Atom, ReturnAtom>(ParseResult<ReturnAtom, {Atom*}>({Atom*}) parser)({Atom*} str)
        given Atom satisfies Object
        given ReturnAtom satisfies Object
        => bind<ReturnAtom, {Atom*}, JustError<[], {Atom*}>, Ok<[], {Atom*}>> {
                (ok) => JustError(str);
                (error) => ok([], str);
            } (parser(str));

// TODO: Normalize newlines?
"Parses an atom if a given [[predicate]] applies."
shared
ParseResult<Atom, {Atom*}> satisfy<Atom>(Boolean(Atom) predicate, String label = "")({Atom*} str)
        given Atom satisfies Object
{
    if (exists first = str.first, predicate(first))
    {
        return ok(first, str.rest);
    }

    return JustError(str, ["Did not satisfy predicate " + label]);
}

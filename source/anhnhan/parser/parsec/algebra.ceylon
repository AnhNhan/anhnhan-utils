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

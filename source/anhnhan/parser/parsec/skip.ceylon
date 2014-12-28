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
        // TODO: Nothing legit?
        return [[], rest(result)];
    }
    else
    {
        return JustError(str);
    }
}

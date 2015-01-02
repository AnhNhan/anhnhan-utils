/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared
ParseResult<Literal[], InputElement> filterEmpty<Literal, InputElement>(ParseResult<Literal[], InputElement> input)
        given Literal satisfies Object
        => applyR<Literal[], InputElement, Literal[]>(input, (lits) => lits.select((lit) => lit != []));

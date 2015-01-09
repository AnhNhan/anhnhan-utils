/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared
ParseResult<Literal[], InputElement> filterEmpty<Literal, InputElement>(ParseResult<Literal[], InputElement> input)
        given Literal satisfies Object
        => applyR<Literal[], InputElement, Literal[]>(input, (lits) => lits.select((lit) => lit != []));

"Success may be skewed due to empty results (e.g. may contain instances of [[Empty]])."
shared
ParseResult<[Literal+], InputElement> forceMany<Literal, InputElement>(ParseResult<Literal[], InputElement> input, String? label = null)
        => input.bind<ParseResult<[Literal+], InputElement>, Error<[Literal+], InputElement>> {
                (_ok)
                {
                    value result = _ok.result;
                    if (nonempty result)
                    {
                        return ok(result, _ok.rest);
                    }
                    // How to force labeling / add rule-name?
                    return JustError(_ok.rest, ["Abrupt ending, expected at least one match ``label else ""``"]);
                };
                (error) => error.toJustError;
            };

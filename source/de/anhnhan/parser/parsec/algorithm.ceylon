/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.language {
    not
}

"Filters out instances of [[Empty]] out of the result list."
shared
ParseResult<Literal[], InputElement> filterEmpty<Literal, InputElement>(ParseResult<Literal[], InputElement> input)
        given Literal satisfies Object
        => applyR(input, (Literal[] lits) => lits.select(not([].equals)));

"Asserts that a given list of results is non-empty. Returns a parse error in
 case of failure.

 Success may be skewed due to empty results (e.g. may contain instances of [[Empty]])."
shared
ParseResult<[Literal+], InputElement> forceMany<Literal, InputElement>(ParseResult<Literal[], InputElement> input, String? label = null)
        => input.bind
            {
                (_ok)
                {
                    value result = _ok.result;
                    if (nonempty result)
                    {
                        return ok(result, _ok.rest);
                    }
                    // How to force labeling / add rule-name?
                    return JustError(_ok.rest, ["Expected at least one match ``label else ""``"]);
                };
                (error) => error.toJustError;
            };

/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared
Ok<Literal, InputElement> requireSuccess<Literal, InputElement>(ParseResult<Literal, InputElement> result)
        => result.bind<Ok<Literal, InputElement>, Nothing>
        {
            (ok) => ok;
            (error)
            {
                // TODO: Error information
                // Returning nothing since assert/throw "return" Anything...
                return nothing;
            };
        };
shared
Ok<Literal, InputElement> requireSuccessP<Literal, InputElement>(Parser<Literal, InputElement> parser)({InputElement*} input)
        => requireSuccess(parser(input));

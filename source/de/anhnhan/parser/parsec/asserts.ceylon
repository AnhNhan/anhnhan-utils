/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared
Ok<Literal, InputElement> requireSuccess<Literal, InputElement>(ParseResult<Literal, InputElement> result)
        => result.bind
        {
            (ok) => ok;
            (error)
            {
                throw Exception(error.string);
            };
        };
shared
Ok<Literal, InputElement> requireSuccessP<Literal, InputElement>(Parser<Literal, InputElement> parser)({InputElement*} input)
        => requireSuccess(parser(input));

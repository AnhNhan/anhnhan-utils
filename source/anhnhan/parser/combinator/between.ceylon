/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared MaybeLiteral<[T, T, T], Ts> between<T, Ts>(MaybeLiteral<T, Ts>(Ts) inbetween)(MaybeLiteral<T, Ts>(Ts) left, MaybeLiteral<T, Ts>(Ts) right)(Ts input)
    given T satisfies Object
    given Ts satisfies {T*}
{
    if (is LiteralResult<T, Ts> left_result = left(input),
        is LiteralResult<T, Ts> between = inbetween(left_result[1]),
        is LiteralResult<T, Ts> right_result = right(between[1]))
    {
        return [[left_result[0], between[0], right_result[0]], right_result[1]];
    }

    return failure;
}

shared MaybeLiteral<[T, T], Ts> interleaved<T, Ts>(MaybeLiteral<T, Ts>(Ts) inbetween)(MaybeLiteral<T, Ts>(Ts) left, MaybeLiteral<T, Ts>(Ts) right)(Ts input)
    given T satisfies Object
    given Ts satisfies {T*}
{
    if (is LiteralResult<[T, T, T], Ts> result = between(inbetween)(left, right)(input))
    {
        return [[result[0][0], result[0][2]], result.rest.first];
    }

    return failure;
}

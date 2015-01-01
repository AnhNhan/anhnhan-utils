/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared MaybeLiteral<[T, T, T], Input> between<T, Input>(MaybeLiteral<T, Input>(Input) inbetween)(MaybeLiteral<T, Input>(Input) left, MaybeLiteral<T, Input>(Input) right)(Input input)
    given T satisfies Object
    given Input satisfies {T*}
{
    if (is Ok<T, Input> left_result = left(input),
        is Ok<T, Input> between = inbetween(left_result[1]),
        is Ok<T, Input> right_result = right(between[1]))
    {
        return [[left_result[0], between[0], right_result[0]], right_result[1]];
    }

    return failure;
}

shared MaybeLiteral<[T, T], Input> interleaved<T, Input>(MaybeLiteral<T, Input>(Input) inbetween)(MaybeLiteral<T, Input>(Input) left, MaybeLiteral<T, Input>(Input) right)(Input input)
    given T satisfies Object
    given Input satisfies {T*}
{
    if (is Ok<[T, T, T], Input> result = between(inbetween)(left, right)(input))
    {
        return [[result[0][0], result[0][2]], result.rest.first];
    }

    return failure;
}

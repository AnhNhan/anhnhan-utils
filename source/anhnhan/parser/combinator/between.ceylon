/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

// TODO: Advance parser input state
shared Failable<[T, T, T]> between<T, Ts>(Failable<T>(Ts) inbetween)(Failable<T>(Ts) left, Failable<T>(Ts) right)(Ts input)
    given T satisfies Object
    given Ts satisfies {T*}
{
    if (is T left_result = left(input), is T between = inbetween(input), is T right_result = right(input))
    {
        return [left_result, between, right_result];
    }

    return failure;
}

shared Failable<[T, T]> interleaved<T, Ts>(Failable<T>(Ts) inbetween)(Failable<T>(Ts) left, Failable<T>(Ts) right)(Ts input)
    given T satisfies Object
    given Ts satisfies {T*}
{
    if (is [T, T, T] result = between(inbetween)(left, right)(input))
    {
        return [result.first, result.rest.first];
    }

    return failure;
}

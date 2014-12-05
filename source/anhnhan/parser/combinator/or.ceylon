/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared MaybeLiteral<T, Ts> or<T, Ts>(MaybeLiteral<T, Ts>(Ts) fun1, MaybeLiteral<T, Ts>(Ts) fun2)(Ts input)
    given T satisfies Object
    given Ts satisfies {T*}
{
    if (is LiteralResult<T, Ts> first = fun1(input))
    {
        return first;
    }
    else if (is LiteralResult<T, Ts> second = fun2(input))
    {
        return second;
    }

    return failure;
}

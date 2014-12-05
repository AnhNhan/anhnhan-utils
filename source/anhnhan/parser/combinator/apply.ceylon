/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared MaybeLiteral<Return, Ts> apply<T, Ts, Return>(Return(T) fun, MaybeLiteral<T, Ts>(Ts) parser)(Ts input)
    given T satisfies Object
    given Ts satisfies {T*}
    given Return satisfies Object
{
    if (is LiteralResult<T, Ts> result = parser(input))
    {
        return [fun(result[0]), result[1]];
    }

    return failure;
}

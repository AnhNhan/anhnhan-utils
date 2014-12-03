/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared Failable<Return> apply<T, Ts, Return>(Return(T) fun, Failable<T>(Ts) parser)(Ts input)
    given T satisfies Object
    given Ts satisfies {T*}
{
    if (is T result = parser(input))
    {
        return fun(result);
    }

    return failure;
}

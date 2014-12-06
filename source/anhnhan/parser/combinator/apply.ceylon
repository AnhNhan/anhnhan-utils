/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared MaybeLiteral<Return, Input> apply<T, Input, Return>(Return(T) fun, MaybeLiteral<T, Input>(Input) parser)(Input input)
    given T satisfies Object
    given Input satisfies {T*}
    given Return satisfies Object
{
    if (is LiteralResult<T, Input> result = parser(input))
    {
        return [fun(result[0]), result[1]];
    }

    return failure;
}

/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared MaybeLiteral<T, Input> or<T, Input>(MaybeLiteral<T, Input>(Input) fun1, MaybeLiteral<T, Input>(Input) fun2)(Input input)
    given T satisfies Object
    given Input satisfies {T*}
{
    if (is LiteralResult<T, Input> first = fun1(input))
    {
        return first;
    }
    else if (is LiteralResult<T, Input> second = fun2(input))
    {
        return second;
    }

    return failure;
}

shared MaybeLiteral<T, Input> anyOf<T, Input>(MaybeLiteral<T, Input>(Input)+ parsers)(Input input)
    given T satisfies Object
    given Input satisfies {T*}
{
    for (parser in parsers)
    {
        if (is LiteralResult<T, Input> result = parser(input))
        {
            return result;
        }
    }

    return failure;
}

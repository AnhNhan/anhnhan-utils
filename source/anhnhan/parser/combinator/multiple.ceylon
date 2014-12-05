/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.collection {
    LinkedList
}

"Applies a rule multiple times on an input. It does not fail if the rule could
 not be applied, instead it returns an empty result. Use [[many]] instead if
 you want to receive a failure instead."
shared MaybeLiteral<{T*}, Ts> some<T, Ts>(MaybeLiteral<T, Ts>(Ts) parser)(Ts input)
    given T satisfies Object
    given Ts satisfies {T*}
{
    variable value _input = input;
    value results = LinkedList<T>();

    while (is LiteralResult<T, Ts> result = parser(_input))
    {
        results.add(result[0]);
        _input = result[1];
    }

    return [results, _input];
}

"Convenience function to apply a rule multiple times on an input and expecting
 at least one result."
shared MaybeLiteral<{T*}, Ts> many<T, Ts>(MaybeLiteral<T, Ts>(Ts) parser)(Ts input)
    given T satisfies Object
    given Ts satisfies {T*}
{
    value results = some(parser)(input);

    if (is LiteralResult<{T*}, Ts> results, results.first.empty)
    {
        return failure;
    }

    return results;
}

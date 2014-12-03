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
// TODO: Advance parser input state
shared {T*} some<T, Ts>(Failable<T>(Ts) parser)(Ts input)
    given T satisfies Object
    given Ts satisfies {T*}
{
    value results = LinkedList<T>();

    while (is T result = parser(input))
    {
        results.add(result);
    }

    return results;
}

"Convenience function to apply a rule multiple times on an input and expecting
 at least one result."
shared Failable<{T*}> many<T, Ts>(Failable<T>(Ts) parser)(Ts input)
    given T satisfies Object
    given Ts satisfies {T*}
{
    value results = some(parser)(input);

    if (results.empty)
    {
        return failure;
    }

    return results;
}

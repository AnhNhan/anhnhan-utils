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
see(`function many`)
shared MaybeLiteral<T[], Input> some<T, Input>(MaybeLiteral<T, Input>(Input) parser)(Input input)
    given T satisfies Object
    given Input satisfies {T*}
{
    variable value _input = input;
    value results = LinkedList<T>();

    while (is Ok<T, Input> result = parser(_input))
    {
        results.add(result[0]);
        _input = result[1];
    }

    return [results.sequence(), _input];
}

"Convenience function to apply a rule multiple times on an input and expecting
 at least one result."
see(`function some`)
shared MaybeLiteral<[T+], Input> many<T, Input>(MaybeLiteral<T, Input>(Input) parser)(Input input)
    given T satisfies Object
    given Input satisfies {T*}
{
    value results = some(parser)(input);

    if (is Failure results)
    {
        return failure;
    }
    else
    {
        // We definitely need better type narrowing, those type asserts are unnecessary
        assert(is Ok<T[], Input> results);
        if (nonempty literal = results.first)
        {
            value tail = results.rest.first;
            return [literal, tail];
        }
        else
        {
            return failure;
        }
    }
}

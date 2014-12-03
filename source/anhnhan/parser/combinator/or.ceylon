/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

// TODO: Advance parser input state
shared Failable<T> or<T, Ts>(Failable<T>(Ts) fun1, Failable<T>(Ts) fun2)(Ts input)
    given T satisfies Object
    given Ts satisfies {T*}
{
    if (is T first = fun1(input))
    {
        return first;
    }
    else if (is T second = fun2(input))
    {
        return second;
    }

    return failure;
}

/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared Return uncurry<Return, First, Second>(Return(Second)(First) fun)(First first, Second second)
        => fun(first)(second);

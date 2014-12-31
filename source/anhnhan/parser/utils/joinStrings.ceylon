/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

"""Joins a list of [[strings]] together, interposed with [[joinWith]].

       String result = joinStrings({"a", "b", "c"}, ".");
       assert(result == "a.b.c");

   It is especially useful to join a list of lines back into a single string."""
shared String joinStrings({String*} strings, String joinWith = "\n")
        => strings.interpose(joinWith).reduce((String? partial, String element) => (partial else "") + element) else "";

/**
    Ceylon PHP Compiler Backend

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.collection {
    MutableMap,
    HashMap
}

shared final
class Name(
    shared
    [String+] parts,
    shared actual
    MutableMap<String, Object> attributes
            = HashMap<String, Object>(),
    shared
    Boolean relative = false
)
        satisfies Node & Renderable
{
    shared
    String first = parts.first;
    shared
    String last = parts.last;

    shared actual
    String render()
            => parts.interpose("\\").fold("")(plus<String>);

    shared
    Boolean unqualified = parts.size == 1;
    shared
    Boolean qualified = 1 < parts.size;
}

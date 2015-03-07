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
    shared
    Boolean relative = true,
    shared actual
    MutableMap<String, Object> attributes
            = HashMap<String, Object>()
)
        satisfies Node & Renderable
{
    shared
    String first = parts.first;
    shared
    String last = parts.last;

    shared actual
    String render()
            => String((relative then "" else "\\").chain { parts.interpose("\\").fold("")(plus<String>); });

    shared
    Boolean unqualified = parts.size == 1;
    shared
    Boolean qualified = 1 < parts.size;
}

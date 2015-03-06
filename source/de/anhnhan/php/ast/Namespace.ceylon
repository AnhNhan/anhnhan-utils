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
class Namespace(
    shared
    Name name,
    shared actual
    {Statement*} statements,
    shared actual
    MutableMap<String, Object> attributes
            = HashMap<String, Object>()
)
        satisfies Statement & SubStatements
{}
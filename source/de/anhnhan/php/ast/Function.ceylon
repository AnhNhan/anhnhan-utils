/**
    Ceylon PHP Compiler Backend

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.collection {
    HashMap,
    MutableMap
}

shared final
class Function(
    shared actual
    String name,
    shared actual
    {FunctionDefinitionParameter*} parameters = {},
    shared actual
    {Statement|Expression*} statements = {},
    shared actual
    Boolean byRef = false,
    shared actual
    MutableMap<String, Object> attributes
            = HashMap<String, Object>()
)
        satisfies FunctionOrMethod
{}

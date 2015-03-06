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
class FunctionCallArgument(
    shared
    Expression expr,
    shared
    Boolean byRef = false,
    shared actual
    MutableMap<String, Object> attributes
            = HashMap<String, Object>()
)
        satisfies Node
{
    shared
    String render() => "``byRef then "&" else ""````expr.render()``";
}

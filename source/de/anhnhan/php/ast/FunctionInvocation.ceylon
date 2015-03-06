/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.collection {
    HashMap,
    MutableMap
}

shared
class FunctionInvocation(
    shared
    VariableReference|PropertyReference|Name func,
    shared
    {FunctionCallArgument*} parameters,
    shared actual
    MutableMap<String, Object> attributes
            = HashMap<String, Object>()
)
        satisfies Expression
{
    render() => "``func.render()``(``parameters*.render().interpose(", ").fold("")(plus<String>)``)";
}

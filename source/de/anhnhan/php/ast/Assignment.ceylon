/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.collection {
    HashMap,
    MutableMap
}

// TODO: Other kinds of assignements
shared
class Assignment(
    shared
    VariableReference|PropertyReference|Assignment lValue,
    shared
    Expression rValue,
    shared actual
    MutableMap<String, Object> attributes
            = HashMap<String, Object>()
)
        satisfies Expression
{
    render() => lValue.render() + " = " + rValue.render();
}

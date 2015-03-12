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
interface Expression
        satisfies Node & Renderable
{
}

shared
class NewObject(
    shared
    Name|VariableReference|StringLiteral className,
    shared actual
    MutableMap<String, Object> attributes
            = HashMap<String, Object>()
)
        satisfies Expression
{
    render() => "new ``className.render()``";
}

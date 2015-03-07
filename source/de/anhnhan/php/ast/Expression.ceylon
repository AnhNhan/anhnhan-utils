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
class ExpressionStatement(
    shared
    Expression expr,
    shared actual
    MutableMap<String, Object> attributes
            = HashMap<String, Object>()
)
        satisfies Statement & Renderable
{
    shared actual
    String render() => "``expr.render()``;";
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

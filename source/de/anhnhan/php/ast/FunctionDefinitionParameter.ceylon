/**
    Ceylon PHP Compiler Backend

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.collection {
    HashMap,
    MutableMap
}

shared
interface SpecialTypeHints
        of callable | array
        satisfies Renderable
{}

shared object callable satisfies SpecialTypeHints { render() => "callable"; }
shared object array satisfies SpecialTypeHints { render() => "array"; }

shared final
class FunctionDefinitionParameter(
    shared
    String name,
    shared
    Expression? defaultValue = null,
    shared
    String|Name|SpecialTypeHints? typeHint = null,
    shared
    Boolean byRef = false,
    shared actual
    MutableMap<String, Object> attributes
            = HashMap<String, Object>()
)
        satisfies Node
{
    shared
    String render()
    {
        String byRef = this.byRef then "&" else "";

        String _typeHint;
        switch (typeHint)
        case (is Null)
        {
            _typeHint = "";
        }
        case (is String)
        {
            _typeHint = typeHint + " ";
        }
        case (is Name|SpecialTypeHints)
        {
            _typeHint = typeHint.render() + " ";
        }

        String expr;
        if (exists defaultValue)
        {
            expr = " = ``defaultValue.render()``";
        }
        else
        {
            expr = "";
        }

        return "``_typeHint````byRef``$``name````expr``";
    }
}

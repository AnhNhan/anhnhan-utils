/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.collection {
    HashMap,
    MutableMap
}
import ceylon.language.meta {
    ceylon_type=type
}

shared final
class VariableReference(
    shared
    String name,
    shared actual
    MutableMap<String, Object> attributes
            = HashMap<String, Object>()
)
        satisfies Expression
{
    render() => "$``name``";
}

shared final
class PropertyReference(
    shared
    Expression objExpr,
    shared
    Expression|String property,
    shared actual
    MutableMap<String, Object> attributes
            = HashMap<String, Object>()
)
        satisfies Expression
{
    if (is Scalar objExpr)
    {
        "We can't call methods on scalars (yet)."
        assert (false);
    }

    shared actual
    String render()
    {
        String obj;
        String property;

        if (is VariableReference|FunctionInvocation objExpr)
        {
            obj = objExpr.render();
        }
        else
        {
            throw Exception("Unsupported object expression: ``ceylon_type(objExpr)``");
        }

        if (is String prop = this.property)
        {
            property = prop;
        }
        else if (is VariableReference|FunctionInvocation prop = this.property)
        {
            property = "{``prop.render()``}";
        }
        else
        {
            throw Exception("Unsupported property expression: ``ceylon_type(this.property)``");
        }

        return "``obj``->``property``";
    }
}

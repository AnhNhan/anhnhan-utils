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

        if (is VariableReference|PropertyReference|FunctionInvocation objExpr)
        {
            obj = objExpr.render();
        }
        else if (is NewObject objExpr)
        {
            obj = "(``objExpr.render()``)";
        }
        else
        {
            throw Exception("Unsupported object expression: ``ceylon_type(objExpr)``");
        }

        if (is String prop = this.property)
        {
            property = prop;
        }
        else if (is VariableReference|PropertyReference|FunctionInvocation prop = this.property)
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

shared final
class StaticReference(
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
    // TODO: Too lazy?
    shared actual
    String render()
    {
        String renderedProperty;
        if (is String property)
        {
            renderedProperty = property;
        }
        else
        {
            renderedProperty = property.render();
        }

        return "``objExpr.render()``::``renderedProperty``";
    }
}

shared
PropertyReference thisRef(Expression|String property)
        => PropertyReference(VariableReference("this"), property);

"Alias for writing less in more time."
shared
VariableReference(String, MutableMap<String, Object>=) varRef
        = `VariableReference`;

"Alias for writing less in more time."
shared
PropertyReference(Expression, Expression|String, MutableMap<String, Object>=) propRef
        = `PropertyReference`;

"Alias for writing less in more time."
shared
StaticReference(Expression, Expression|String, MutableMap<String, Object>=) staticRef
        = `StaticReference`;

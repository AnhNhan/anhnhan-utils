/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared sealed interface Node
    of Expression | Statement
{
    shared formal String name;
    shared formal Node[] subNodes;
}

shared sealed interface Expression
    satisfies Node
{
    shared formal actual Expression[] subNodes;
}

shared sealed interface Statement
    satisfies Node
{
    shared formal actual Node[] subNodes;
}

shared final class TypeName(typeName, typeQualifiedName)
        satisfies Expression
{
    shared actual String name => `class TypeName`.name;
    shared actual Empty subNodes = [];

    assert(typeName in typeQualifiedName);

    shared String typeName;
    shared String typeQualifiedName;
}

shared interface ConditionalExpression
    satisfies Expression
{
}

shared final class ConditionalStatement(conditionalExpression, subNodes, elseNodes = [])
    satisfies Statement
{
    shared actual String name = `class ConditionalStatement`.name;

    shared ConditionalExpression conditionalExpression;

    shared actual Node[] subNodes;
    shared Node[] elseNodes;
}

shared final class AssertStatement(subNodes)
    satisfies Statement
{
    shared actual String name = `class AssertStatement`.name;

    "E.g. `assert(a, b, c);` translates to `[a, b, c]`"
    shared actual ConditionalExpression[] subNodes;
}

shared final class ValueExpression()
    satisfies Expression & ConditionalExpression
{
    shared actual String name = `class ValueExpression`.name;

    shared actual Empty subNodes = [];
}

shared final class IsExpression(isType, subNodes)
    satisfies Expression & ConditionalExpression
{
    shared actual String name = `class IsExpression`.name;

    shared actual [Expression+] subNodes;

    shared TypeName isType;

    value lastExpr = subNodes.last;
    assert(is ValueExpression lastExpr);
    shared ValueExpression operand = lastExpr;
}

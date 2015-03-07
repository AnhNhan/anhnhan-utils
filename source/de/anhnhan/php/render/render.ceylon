/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import de.anhnhan.php.ast {
    Namespace,
    Class,
    Interface,
    Function,
    Method,
    Property,
    Const,
    ClassOrInterface,
    Statement,
    FunctionOrMethod,
    Return,
    ExpressionStatement,
    Use
}

String indent(Integer depth, String pad = "    ")
        => pad.repeat(depth);

String padLines(Integer depth, String pad = "    ")(String str)
        => str.linesWithBreaks.map((line) => indent(depth) + line).fold("")(plus<String>);

shared
String renderStatement(Statement stmt, Integer scopeDepth = 0)
{
    switch (stmt)
    case (is Const | Use | Property | ExpressionStatement)
    {
        return indent(scopeDepth) + stmt.render();
    }
    case (is Class | Interface)
    {
        return renderClassOrInterface(stmt, scopeDepth);
    }
    case (is Function | Method)
    {
        return renderFunctionOrMethod(stmt, scopeDepth);
    }
    case (is Namespace)
    {
        return padLines(scopeDepth)("namespace ``stmt.name.render()``
                                     {
                                     ``stmt.statements.map(renderStatementInv(1)).interpose("\n").fold("")(plus<String>)``
                                     }");
    }
    case (is Return)
    {
        return indent(scopeDepth) + "return ``stmt.expr?.render() else ""``;";
    }
}

String renderStatementInv(Integer scopeDepth)(Statement stmt)
        => renderStatement(stmt, scopeDepth);

shared
String renderFunctionOrMethod(FunctionOrMethod obj, Integer scopeDepth = 0)
{
    String modifiers;
    if (is Method obj)
    {
        modifiers = obj.modifiers*.render().interpose(" ").fold("")(plus<String>) + " ";
    }
    else
    {
        modifiers = "";
    }

    return padLines(scopeDepth)("``modifiers``function ``obj.name``(``obj.parameters*.render().interpose(", ").fold("")(plus<String>)``) {
                                 ``obj.statements.map(renderStatementInv(1)).interpose("\n").fold("")(plus<String>)``
                                 }
                                 ");
}

shared
String renderClassOrInterface(ClassOrInterface obj, Integer scopeDepth = 0)
{
    value keyword = obj.abstract then "interface" else "class";
    String _extends;
    String implements;

    switch (obj)
    case (is Class)
    {
        if (exists __extends = obj._extends)
        {
            // TODO: Namespacing?
            _extends = "extends ``__extends.render()`` ";
        }
        else
        {
            _extends = "";
        }
    }
    case (is Interface)
    {
        _extends = "";
    }

    if (nonempty _implements = obj.implements)
    {
        implements = "implements ``_implements*.render().interpose(",").fold("")(plus<String>)`` ";
    }
    else
    {
        implements = "";
    }

    return "``indent(scopeDepth)````keyword`` ``obj.name`` ``_extends````implements``{
            ``obj.statements.map(renderStatementInv(scopeDepth + 1)).interpose("\n").fold("")(plus<String>)``
            ``indent(scopeDepth)``}";
}

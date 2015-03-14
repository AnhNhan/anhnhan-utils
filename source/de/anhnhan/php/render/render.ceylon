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
    Use,
    preprocessModifiers,
    Expression
}

String indent(Integer depth, String pad = "    ")
        => pad.repeat(depth);

String indentLines(Integer depth, String pad = "    ")(String str)
        => "".join(str.linesWithBreaks.map((line) => indent(depth) + line));

shared
String render(Statement|Expression stmt, Integer scopeDepth = 0)
{
    switch (stmt)
    case (is Const | Use | Property | Expression)
    {
        return indentLines(scopeDepth)(stmt.renderAsStatement());
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
        return indentLines(scopeDepth)("namespace ``stmt.name.render()``
                                        {
                                        ``"\n".join(stmt.statements.map(renderStatementInv(1)))``
                                        }");
    }
    case (is Return)
    {
        return indent(scopeDepth) + "return ``stmt.expr?.render() else ""``;";
    }
}

String renderStatementInv(Integer scopeDepth)(Statement|Expression stmt)
        => render(stmt, scopeDepth);

shared
String renderFunctionOrMethod(FunctionOrMethod obj, Integer scopeDepth = 0)
{
    String modifiers;
    if (is Method obj)
    {
        modifiers = " ".join(preprocessModifiers(obj.modifiers)*.render()) + " ";
    }
    else
    {
        modifiers = "";
    }

    return indentLines(scopeDepth)("``modifiers``function ``obj.name``(``", ".join(obj.parameters*.render())``) {
                                    ``"\n".join(obj.statements.map(renderStatementInv(1)))``
                                    }
                                    ");
}

shared
String renderClassOrInterface(ClassOrInterface obj, Integer scopeDepth = 0)
{
    value keyword = obj is Interface then "interface" else "class";
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
        implements = "implements ``", ".join(_implements*.render())`` ";
    }
    else
    {
        implements = "";
    }

    return "``indent(scopeDepth)````keyword`` ``obj.name`` ``_extends````implements``{
            ``"\n".join(obj.statements.map(renderStatementInv(scopeDepth + 1)))``
            ``indent(scopeDepth)``}";
}

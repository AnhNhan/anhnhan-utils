/**
    Ceylon PHP Compiler Backend

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.collection {
    HashMap,
    MutableMap
}

{String+} reservedClassNames = ["self", "parent", "static"];

shared
interface Modifyable
{
    shared formal
    {Modifier*} modifiers;

    shared
    Boolean abstract => _abstract in modifiers;
}

shared
interface Modifier
        of public | protected | private | _static | _abstract | _final
{
    shared formal
    String render();
}

shared object public satisfies Modifier { render() => "public"; }
shared object protected satisfies Modifier { render() => "protected"; }
shared object private satisfies Modifier { render() => "private"; }
shared object _static satisfies Modifier { render() => "static"; }
shared object _abstract satisfies Modifier { render() => "abstract"; }
shared object _final satisfies Modifier { render() => "final"; }

shared
interface ClassOrInterface
        of Class | Interface
        satisfies Statement & Modifyable & SubStatements
{
    shared formal
    String name;

    shared formal
    Name[] implements;

    shared formal
    {DocAnnotation*} annotations;

    shared actual formal
    {TypeDeclarationBodyStatement*} statements;
}

shared final
class Class(
    shared actual
    String name,
    shared actual
    {Modifier*} modifiers,
    shared
    Name? _extends = null,
    shared actual
    Name[] implements = [],
    shared actual
    {TypeDeclarationBodyStatement*} statements = [],
    shared actual
    {DocAnnotation*} annotations = {},
    shared actual
    MutableMap<String, Object> attributes
            = HashMap<String, Object>()
)
        satisfies Statement & SubStatements & Modifyable & ClassOrInterface
{
    if (name in reservedClassNames)
    {
        throw Exception("Cannot use ``name`` as a class name.");
    }
}

shared final
class Interface(
    shared actual
    String name,
    shared actual
    {Modifier*} modifiers,
    shared actual
    Name[] implements = [],
    shared actual
    {TypeDeclarationBodyStatement*} statements = [],
    shared actual
    {DocAnnotation*} annotations = {},
    shared actual
    MutableMap<String, Object> attributes
            = HashMap<String, Object>()
)
        satisfies SubStatements & Modifyable & ClassOrInterface
{
    if (name in reservedClassNames)
    {
        throw Exception("Cannot use ``name`` as an interface name.");
    }
}

shared final
class Const(
    shared
    String name,
    shared
    Expression expr,
    shared actual
    {Modifier*} modifiers = {},
    shared actual
    MutableMap<String, Object> attributes
            = HashMap<String, Object>()
)
        satisfies TypeDeclarationBodyStatement & Modifyable & Renderable
{
    render() => "``_static in modifiers then "static " else ""`` const ``name`` = ``expr.render()``;";
}

"For class and interface members, not for classes and interfaces themselves."
shared
{Modifier*} preprocessModifiers({Modifier*} modifiers)
        => !modifiers.containsAny { public, protected }
            then {private, *modifiers}
            else modifiers;

shared
String renderDocBlock({DocAnnotation*} annotations)
{
    if (annotations.empty)
    {
        return "";
    }
    assert (is [DocAnnotation+] _annotations = annotations.sequence());
    return "/**
            ``"\n".join(_annotations*.render().map((str) => " * " + str))``
             */\n";
}

shared final
class Method(
    shared
    Function func,
    shared actual
    {Modifier*} modifiers = {},
    shared
    {DocAnnotation*} annotations = {},
    shared
    Boolean inInterface = false,
    shared actual
    MutableMap<String, Object> attributes
            = HashMap<String, Object>()
)
        satisfies FunctionOrMethod & Modifyable
{
    if (func.name in ["__construct", "__destruct", "__clone"], _static in modifiers)
    {
        throw Exception("Method ``func.name`` cannot be static.");
    }

    name = func.name;
    statements = func.statements;
    parameters = func.parameters;
    byRef = func.byRef;
}

shared final
class Property(
    shared
    String name,
    shared
    Expression? default = null,
    shared actual
    {Modifier*} modifiers = {},
    shared
    {DocAnnotation*} annotations = {},
    shared actual
    MutableMap<String, Object> attributes
            = HashMap<String, Object>()
)
        satisfies TypeDeclarationBodyStatement & Modifyable & Renderable
{
    shared actual
    String render()
    {
        {Modifier*} computedModifiers = preprocessModifiers(modifiers);

        value _modifiers = !computedModifiers.empty then (computedModifiers*.render().interpose(" ").fold("")(plus<String>) + " ") else "";
        value expr = default exists then " = ``default?.render() else nothing``" else "";
        return "``renderDocBlock(annotations)````_modifiers``$``name````expr``;";
    }
}

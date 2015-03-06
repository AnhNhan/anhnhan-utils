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
}

shared
interface Modifier
        of public | protected | private | static | _abstract | _final
{
    shared formal
    String render();
}

shared object public satisfies Modifier { render() => "public"; }
shared object protected satisfies Modifier { render() => "protected"; }
shared object private satisfies Modifier { render() => "private"; }
shared object static satisfies Modifier { render() => "static"; }
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

    shared
    Boolean abstract
            => _abstract in (this of Modifyable).modifiers;
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
    {Statement*} statements = [],
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
    {Statement*} statements = [],
    shared actual
    MutableMap<String, Object> attributes
            = HashMap<String, Object>()
)
        satisfies Statement & SubStatements & Modifyable & ClassOrInterface
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
        satisfies Statement & Modifyable
{
    shared
    String render() => "``static in modifiers then "static " else ""`` const ``name`` = ``expr.render()``;";
}

shared final
class Method(
    shared
    Function func,
    shared actual
    {Modifier*} modifiers,
    shared actual
    MutableMap<String, Object> attributes
            = HashMap<String, Object>()
)
        satisfies FunctionOrMethod & Modifyable
{
    if (func.name in ["__construct", "__destruct", "__clone"], static in modifiers)
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
    shared actual
    MutableMap<String, Object> attributes
            = HashMap<String, Object>()
)
        satisfies Statement & Modifyable
{
    shared
    String render()
    {
        value modifiers = !this.modifiers.empty then (this.modifiers*.render().interpose(" ").fold("")(plus<String>) + " ") else "";
        value expr = default exists then " = ``default?.render() else nothing``" else "";
        return "``modifiers``$``name````expr``;";
    }
}

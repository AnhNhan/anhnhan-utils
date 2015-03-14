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
interface SpecialClassRef
        of static | self | parent
        satisfies Expression
{
    // Dead. Gets re-initialized on every invokation.
    shared actual
    MutableMap<String, Object> attributes
            => HashMap<String, Object>();
}

shared object static satisfies SpecialClassRef { render() => "static"; }
shared object self satisfies SpecialClassRef { render() => "self"; }
shared object parent satisfies SpecialClassRef { render() => "parent"; }

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

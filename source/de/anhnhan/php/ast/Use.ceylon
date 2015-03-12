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
class Use(
    shared
    {<Name->String?>+} uses,
    shared actual
    MutableMap<String, Object> attributes
            = HashMap<String, Object>()
)
        satisfies TypeDeclarationBodyStatement & Renderable
{
    render()
            => "use ``uses.map((use) => use.key.render() + (use.item exists then " as ``(use.item else nothing)``" else "")).interpose(", ").fold("")(plus<String>)``;";
}

/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared
interface SubStatements
{
    shared formal
    {Statement|Expression*} statements;
}

shared
interface Statement
        of TypeDeclarationBodyStatement | ClassOrInterface | Namespace | Return
        satisfies Node
{}

"Statements allowed in a class-/interface-body context.

 Most of these are still
 allowed in different contexts though, they were simply placed here to make use
 of Ceylon's enumerated types."
shared
interface TypeDeclarationBodyStatement
        of FunctionOrMethod | Const | Property | Use
        satisfies Statement
{}

shared
interface FunctionOrMethod
        of Function | Method
        satisfies TypeDeclarationBodyStatement & SubStatements
{
    shared formal
    String name;

    shared formal
    {FunctionDefinitionParameter*} parameters;

    shared formal
    Boolean byRef;
}

/**
    Ceylon PHP Compiler Backend

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.collection {
    MutableMap
}

import de.anhnhan.php.ast {
    ExpressionStatement
}

shared
interface Node
        of Name | Expression | Statement | FunctionCallArgument | FunctionDefinitionParameter | DocAnnotation
{
    shared
    String type => className(this);

    shared formal
    MutableMap<String, Object> attributes;

    Type? attr<Type>(String key)
            given Type satisfies Object
    {
        if (is Type val = attributes[key])
        {
            return val;
        }
        return null;
    }

    shared
    Integer? line
            => attr<Integer>("startLine");
    assign line
    {
        if (exists line)
        {
            attributes.put("startLine", line);
        }
        else
        {
            attributes.remove("startLine");
        }
    }
}

shared
interface SubStatements
{
    shared formal
    {Statement*} statements;
}

shared
interface Statement
        of ClassOrInterface | FunctionOrMethod | Const | Property | Namespace | Return | ExpressionStatement | Use
        satisfies Node
{}

shared
interface FunctionOrMethod
        of Function | Method
        satisfies Statement & SubStatements
{
    shared formal
    String name;

    shared formal
    {FunctionDefinitionParameter*} parameters;

    shared formal
    Boolean byRef;
}

shared
interface Expression
        satisfies Node & Renderable
{
}

shared
interface Scalar
        of StringLiteral | NumberLiteral | BooleanLiteral | phpNull
        satisfies Expression
{}

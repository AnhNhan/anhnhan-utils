/**
    Ceylon PHP Compiler Backend

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.collection {
    MutableMap
}

import de.anhnhan.php.ast {
    Expression
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
interface Scalar
        of StringLiteral | NumberLiteral | BooleanLiteral | phpNull
        satisfies Expression
{}

/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import anhnhan.parser.parsec {
    apply,
    Parser
}

shared
interface ParseTree<out InputElement>
        of Token<InputElement>
            | Nodes<InputElement>
{
    shared formal
    String name;
}

shared
interface Token<out InputElement>
        satisfies ParseTree<InputElement>
{
    shared formal
    [InputElement+] token;
}

shared
interface Nodes<out InputElement>
        satisfies ParseTree<InputElement>
{
    shared formal
    ParseTree<InputElement>[] nodes;
}

shared
Token<InputElement> token<InputElement>(String tokenName)([InputElement+] lits)
{
    object token
            satisfies Token<InputElement>
    {
        name = tokenName;
        token = lits;
    }
    return token;
}

shared
Parser<Token<Literal>, InputElement> tokenParser<Literal, InputElement>(String tokenName, Parser<[Literal+], InputElement> parser)
        => apply(parser, token<Literal>(tokenName));

shared
Nodes<InputElement> nodes<InputElement>(String nodeName)(ParseTree<InputElement>[] elements)
{
    object nodes
            satisfies Nodes<InputElement>
    {
        name = nodeName;
        nodes = elements;
    }
    return nodes;
}

shared
Parser<Nodes<Literal>, InputElement> nodeParser<Literal, InputElement>(String nodeName, Parser<ParseTree<Literal>[], InputElement> parser)
        => apply(parser, nodes<Literal>(nodeName));

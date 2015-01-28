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

    shared formal
    String render(Integer level = 0);
}

shared
interface Token<out InputElement>
        satisfies ParseTree<InputElement>
{
    shared formal
    InputElement[] token;

    shared actual
    Boolean equals(Object that)
    {
        if (is Token<InputElement> that) {
            return name==that.name && token==that.token;
        }
        else {
            return false;
        }
    }

    hash => name.hash*31 + 7 + token.hash;
}

shared
interface Nodes<out InputElement>
        satisfies ParseTree<InputElement>
{
    shared formal
    ParseTree<InputElement>[] nodes;

    shared actual
    Boolean equals(Object that)
    {
        if (is Nodes<InputElement> that) {
            return name==that.name && nodes==that.nodes;
        }
        else {
            return false;
        }
    }

    hash => name.hash*31 + 7 + nodes.hash;
}

class TokenObj<InputElement>(
    shared actual
    String name,
    shared actual
    InputElement[] token
)
        extends Object()
        satisfies Token<InputElement>
{
    shared actual
    String render(Integer level) => "  > ``name``=>``token``";
}

class NodesObj<InputElement>(
    shared actual
    String name,
    shared actual
    ParseTree<InputElement>[] nodes
)
        extends Object()
        satisfies Nodes<InputElement>
{
    shared actual
    String render(Integer level)
            => "{  ``name`` =>
                ``nodes*.render(level + 1)*.lines*.map((_) => _.padLeading((level + 1) * 4))*.interpose("\n").fold<{String*}>({})(uncurry(Iterable<String>.chain<String, Null>)).fold("")(plus<String>)``
                }";
}

shared
Token<InputElement> token<InputElement>(String tokenName)({InputElement*} lits)
        => TokenObj(tokenName, lits.sequence());

shared
Parser<Token<Literal>, InputElement> tokenParser<Literal, InputElement>(String tokenName, Parser<Literal[], InputElement> parser)
        => apply(parser, token<Literal>(tokenName));

shared
Nodes<InputElement> nodes<InputElement>(String nodeName)(ParseTree<InputElement>[] elements)
        => NodesObj(nodeName, elements);

shared
Parser<Nodes<Literal>, InputElement> nodeParser<Literal, InputElement>(String nodeName, Parser<ParseTree<Literal>[], InputElement> parser)
        => apply(parser, nodes<Literal>(nodeName));

/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import de.anhnhan.parser.parsec {
    anyOf,
    literals,
    literal,
    or,
    manySatisfy,
    right,
    oneOrMore,
    sequence,
    anyLiteral,
    between,
    ignore,
    manyOf,
    ignoreSurrounding,
    emptyLiteral,
    leftRrightS,
    label,
    expected,
    left,
    not,
    zeroOrMore,
    separatedBy,
    ok
}
import de.anhnhan.parser.parsec.string {
    backslashEscapable,
    whitespace,
    StringParser,
    StringParseResult
}
import de.anhnhan.parser.parsec.test {
    assertCanParseWithNothingLeft
}
import de.anhnhan.parser.tree {
    nodeParser,
    tokenParser,
    Nodes,
    Token,
    ParseTree,
    nodes
}

import ceylon.collection {
    HashMap
}
import ceylon.language {
    _or=or
}
import ceylon.test {
    test,
    assertEquals
}

shared
StringParser<Nodes<Character>> parseGrammar
        = nodeParser(
            "Grammar",
            leftRrightS(
                zeroOrMore(parseRule),
                label(
                    emptyLiteral<Character>,
                    "This probably means that we failed parsing pre-maturely."
                )
            )
        );

StringParser<[]> ignores
        = ignore(manyOf(
            whitespace,
            pComment
        ));
StringParser<Literal> s_ign<Literal>(StringParser<Literal> parser)
        => ignoreSurrounding<Literal, Character>(ignores)(parser);

StringParser<Character|Character[]> ruleChar
        = anyOf(
            literals(":="),
            literal(':'),
            literal('=')
        );

StringParser<Token<Character>> ruleStart
        = leftRrightS(s_ign(name), s_ign(ruleChar));

test
void testRuleStart()
{
    {
        "  ABC:   ",
        "(*cool*)foo/*hi*/:=(*hurr*)"
    }.collect(assertCanParseWithNothingLeft(ruleStart));
}

StringParser<Nodes<Character>> parseRule
        = nodeParser(
            "Rule",
            sequence(
                ruleStart,
                nodeParser(
                    "Expressions",
                    oneOrMore(expression)
                )
            )
        );

test
void testParseRule()
{
    {
        "S:S",
        "S := 'hi' B C",
        "S: | A B
            | C D
            | E F"
    }.collect(assertCanParseWithNothingLeft(parseRule));
    {
        "S:S S:S",
        "A:B C|D E Y:Z"
    }.collect(assertCanParseWithNothingLeft(oneOrMore(parseRule)));
}

StringParseResult<ParseTree<Character>> expression({Character*} input)
        => s_ign(anyOf(
            alternation,
            suffixedAtomarExpression
        ))(input);

StringParser alternationChar = or(literal('|'), literal('/'));

StringParser<ParseTree<Character>> alternation
        = right(
            s_ign(ignore(alternationChar)),
            nodeParser(
                "Alternation",
                separatedBy(
                    nodeParser("Branch", oneOrMore(s_ign(suffixedAtomarExpression))),
                    s_ign(alternationChar)
                )
            )
        );

test
void testAlternation()
{
    {
        "A B C",
        "A B|C",
        "A B | (C|D)"
    }.collect(assertCanParseWithNothingLeft(alternation));

    value result1 = alternation("A B C | D foo := bar");
    assertEquals(result1.rest, "foo := bar");
}

"Like [[expression]], but without alternation, infix or postfix operators, or
 any other parsers causing left-recursives trouble.

 Oh, and they are pretty much single-element."
StringParser<ParseTree<Character>> atomarExpression
        = anyOf(
            pSingleQuoteString,
            pDoubleQuoteString,
            pHiddenElement,
            pGroup,
            optionalGroup,
            pEpsilon,
            left(name, s_ign(not(ruleChar)))
        );

StringParser<Token<Character>> name
        = expected(tokenParser("Name", manySatisfy(_or(Character.letter, Character.digit))), "name");

StringParser<Nodes<Character>> optionalGroup
        = nodeParser("Optional", between(s_ign(literal('[')), expression, s_ign(literal(']'))));

StringParser<Token<Character>> pEpsilon
        = tokenParser("Epsilon", anyOf(
            literals("\{GREEK SMALL LETTER EPSILON}"),
            literals("Epsilon"),
            literals("epsilon"),
            literals("EPSILON"),
            literals("eps"),
            literals("\"\""),
            literals("''")
        ));

Character stringEscapeMap(Character lit)
        => HashMap { entries = {
                't' -> '\t',
                'n' -> '\n'
            }; }.get(lit) else lit;

StringParser<Token<Character>> pSingleQuoteString
        => tokenParser("String", backslashEscapable(literal('\''), stringEscapeMap));
StringParser<Token<Character>> pDoubleQuoteString
        => tokenParser("String", backslashEscapable(literal('"'), stringEscapeMap));

StringParser<Nodes<Character>> pHiddenElement
        = nodeParser("HiddenElement", between(s_ign(literal('<')), expression, s_ign(literal('>'))));

StringParser<Nodes<Character>> pGroup
        = nodeParser("Group", between(s_ign(literal('(')), expression, s_ign(literal(')'))));

test
void testPGroup()
{
    {
        "   ( )   ",
        "((( A )))",
        "(((* *)))",
        "( A B C )",
        "(A B | C)"
    }.collect(assertCanParseWithNothingLeft(pGroup));
}

StringParseResult<Token<Character>> pComment({Character*} input)
        => tokenParser("Comment", or(
            between(literals("(*"), anyLiteral<Character>, literals("*)")),
            between(literals("/*"), anyLiteral<Character>, literals("*/"))
        ))(input).label("Comment");

test
void testPComment()
{
    value strs = {
        "(* cool comment, yo? *)",
        "/*********************/",
        "/**/",
        "(**)",
        "(*(**)",
        "(*hi*)"
    };
    strs.collect(assertCanParseWithNothingLeft(pComment));
}

StringParseResult<ParseTree<Character>> suffixedAtomarExpression({Character*} input)
        => atomarExpression(input).bind
        {
            (exprOk)
            {
                switch (exprOk.rest.first)
                case ('?')
                { return ok(nodes<Character>("Optional")([exprOk.result]), exprOk.rest.rest); }
                case ('+')
                { return ok(nodes<Character>("OneOrMore")([exprOk.result]), exprOk.rest.rest); }
                case ('*')
                { return ok(nodes<Character>("ZeroOrMore")([exprOk.result]), exprOk.rest.rest); }
                else
                { return exprOk; }
            };
            (error) => error;
        };

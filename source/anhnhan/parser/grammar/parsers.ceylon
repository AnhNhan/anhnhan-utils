/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import anhnhan.parser {
    Characters
}
import anhnhan.parser.parsec {
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
    until
}
import anhnhan.parser.parsec.string {
    backslashEscapable,
    whitespace,
    StringParser,
    StringParseResult
}
import anhnhan.parser.parsec.test {
    assertCanParseWithNothingLeft
}
import anhnhan.parser.tree {
    nodeParser,
    tokenParser,
    Nodes,
    Token,
    ParseTree
}

import ceylon.collection {
    HashMap
}
import ceylon.language {
    _or=or
}
import ceylon.test {
    test
}

shared
StringParser<Nodes<Character>> parseGrammar
        = nodeParser("Grammar", leftRrightS(oneOrMore(parseRule), label(emptyLiteral<Character>, "This probably means that we failed parsing pre-maturely.")));

StringParser<[]> ignores
        = ignore(manyOf(
            whitespace,
            pComment,
            // Some grammars write their rules like A + B + C. Just ignore them.
            literal('+')
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
                    until(
                        or(ruleStart, emptyLiteral<Character>),
                        expression
                    )
                )
            )
        );

test
void testParseRule()
{
    {
        "S:S",
        "S := 'hi' B C"
    }.collect(assertCanParseWithNothingLeft(parseRule));
    {
        "S:S S:S",
        "A:B+C|D+E+F:G"
    }.collect(assertCanParseWithNothingLeft(oneOrMore(parseRule))).collect(print);
}

StringParseResult<ParseTree<Character>> expression(Characters input)
        => s_ign(or(
            alternation,
            atomarExpressions
        ))(input);

StringParser alternationChar = or(literal('|'), literal('/'));

StringParser<ParseTree<Character>> alternation
        = nodeParser(
            "Alternation",
            oneOrMore<ParseTree<Character>, Character>(
                nodeParser(
                    "Branch",
                    right(
                        s_ign(ignore(alternationChar)),
                        oneOrMore<ParseTree<Character>, Character>(
                            atomarExpression
                        )
                    )
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
}

StringParser<ParseTree<Character>> atomarExpressions
        = nodeParser("Expressions", oneOrMore(s_ign(atomarExpression)));

"Like [[expression]], but without alternation, infix or postfix operators, or
 any other parsers causing left-recursives trouble."
StringParser<ParseTree<Character>> atomarExpression
        = left(anyOf(
            pSingleQuoteString,
            pDoubleQuoteString,
            pHiddenElement,
            pGroup,
            pEpsilon,
            name
        ), or(ruleStart, emptyLiteral<Character>));

StringParser<Token<Character>> name
        = expected(tokenParser("Name", manySatisfy(_or(Character.letter, Character.digit))), "name");

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

StringParseResult<Token<Character>> pComment(Characters input)
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

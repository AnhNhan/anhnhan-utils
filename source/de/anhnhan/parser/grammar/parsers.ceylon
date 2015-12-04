/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

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
	ok,
	ParseResult,
	Parser
}
import de.anhnhan.parser.parsec.string {
	backslashEscapable,
	whitespace
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

shared
Parser<Nodes<Character>, Character> parseGrammar
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

Parser<[], Character> ignores
        = ignore(manyOf(
            whitespace,
            pComment
        ));
Parser<Literal, Character> s_ign<Literal>(Parser<Literal, Character> parser)
        => ignoreSurrounding<Literal, Character>(ignores)(parser);

Parser<Character|Character[], Character> ruleChar
        = anyOf(
            literals(":="),
            literal(':'),
            literal('=')
        );

Parser<Token<Character>, Character> ruleStart
        = leftRrightS(s_ign(name), s_ign(ruleChar));

test
void testRuleStart()
{
    {
        "  ABC:   ",
        "(*cool*)foo/*hi*/:=(*hurr*)"
    }.collect(assertCanParseWithNothingLeft(ruleStart));
}

Parser<Nodes<Character>, Character> parseRule
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

ParseResult<ParseTree<Character>, Character> expression({Character*} input)
        => s_ign(anyOf(
            alternation,
            suffixedAtomarExpression
        ))(input);

Parser<Character, Character> alternationChar = or(literal('|'), literal('/'));

Parser<ParseTree<Character>, Character> alternation
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
Parser<ParseTree<Character>, Character> atomarExpression
        = anyOf(
            pSingleQuoteString,
            pDoubleQuoteString,
            pHiddenElement,
            pGroup,
            optionalGroup,
            pEpsilon,
            left(name, s_ign(not(ruleChar)))
        );

Parser<Token<Character>, Character> name
        = expected(tokenParser("Name", manySatisfy(_or(Character.letter, Character.digit))), "name");

Parser<Nodes<Character>, Character> optionalGroup
        = nodeParser("Optional", between(s_ign(literal('[')), expression, s_ign(literal(']'))));

Parser<Token<Character>, Character> pEpsilon
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

Parser<Token<Character>, Character> pSingleQuoteString
        => tokenParser("String", backslashEscapable(literal('\''), stringEscapeMap));
Parser<Token<Character>, Character> pDoubleQuoteString
        => tokenParser("String", backslashEscapable(literal('"'), stringEscapeMap));

Parser<Nodes<Character>, Character> pHiddenElement
        = nodeParser("HiddenElement", between(s_ign(literal('<')), expression, s_ign(literal('>'))));

Parser<Nodes<Character>, Character> pGroup
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

ParseResult<Token<Character>, Character> pComment({Character*} input)
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

ParseResult<ParseTree<Character>, Character> suffixedAtomarExpression({Character*} input)
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

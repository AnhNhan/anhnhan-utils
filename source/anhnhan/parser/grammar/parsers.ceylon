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
    betweenLiteral,
    oneOrMore,
    negativeLookahead,
    sequence,
    left,
    anyLiteral,
    between,
    ignore,
    manyOf,
    ignoreSurrounding,
    emptyLiteral,
    leftRrightS
}
import anhnhan.parser.parsec.string {
    backslashEscapable,
    whitespace,
    StringParser,
    StringParseResult
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

shared
StringParser<Nodes<Character>> parseGrammar
        = nodeParser("Grammar", leftRrightS(oneOrMore(s_ign(parseRule)), emptyLiteral<Character>));

StringParser<[]> ignores
        = ignore(manyOf(
            pComment,
            whitespace
        ));
StringParser<Literal> s_ign<Literal>(StringParser<Literal> parser)
        => ignoreSurrounding<Literal, Character>(ignores)(parser);

StringParser<Character|Character[]> ruleChar
        = anyOf(
            literal(':'),
            literal('='),
            literals(":=")
        );

StringParser<Token<Character>> ruleStart
        = leftRrightS(name, s_ign(ruleChar));

StringParser<Nodes<Character>> parseRule
        = nodeParser(
            "Rule",
            sequence(
                ruleStart,
                left(
                    nodeParser(
                        "Expressions",
                        oneOrMore(s_ign(expression))
                    ),
                    negativeLookahead(ruleStart)
                )
            )
        );

StringParseResult<ParseTree<Character>> expression(Characters input)
        => or<ParseTree<Character>, ParseTree<Character>, Character>(
            alternation,
            atomarExpressions
        )(input);

StringParser alternationChar = or(literal('|'), literal('/'));

StringParser<ParseTree<Character>> alternation
        = or(
            right(alternationChar, alternationAtom),
            alternationAtom
        );

StringParser<ParseTree<Character>> alternationAtom
        = nodeParser(
            "Alternation",
            oneOrMore<ParseTree<Character>, Character>(
                nodeParser(
                    "Branch",
                    s_ign(right(
                        alternationChar,
                        oneOrMore<ParseTree<Character>, Character>(
                            s_ign(atomarExpression)
                        )
                    ))
                )
            )
        );

StringParser<ParseTree<Character>> atomarExpressions
        = nodeParser("Expressions", oneOrMore<ParseTree<Character>, Character>(s_ign(atomarExpression)));

"Like [[expression]], but without alternation, infix or postfix operators, or
 any other parsers causing left-recursives trouble."
StringParser<ParseTree<Character>> atomarExpression
        = anyOf(
            pSingleQuoteString,
            pDoubleQuoteString,
            pHiddenElement,
            pGroup,
            pEpsilon,
            name
        );

StringParser<Token<Character>> name = tokenParser("Name", manySatisfy(_or(Character.letter, Character.digit), "name"));

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
        = nodeParser("HiddenElement", betweenLiteral('<', expression, '>'));

StringParser<Nodes<Character>> pGroup
        = nodeParser("Group", betweenLiteral('(', expression, ')'));

StringParser<Token<Character>> pComment
        = tokenParser("Comment", or(
            between(literals("(*"), anyLiteral<Character>, literals("*)")),
            between(literals("/*"), anyLiteral<Character>, literals("*/"))
        ));

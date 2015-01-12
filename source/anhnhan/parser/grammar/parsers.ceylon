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
    emptyLiteral
}
import anhnhan.parser.parsec.string {
    backslashEscapable,
    whitespace,
    StringParser,
    StringParseResult
}
import anhnhan.parser.tree {
    StringToken,
    StringNodes,
    nodeParser,
    tokenParser,
    StringParseTree
}

import ceylon.collection {
    HashMap
}

shared
StringParser<StringNodes> parseGrammar
        = nodeParser("Grammar", left(oneOrMore(s_ign(parseRule)), emptyLiteral<Character>));

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

StringParser<StringToken> ruleStart
        = left(name, s_ign(ruleChar));

StringParser<StringNodes> parseRule
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

StringParseResult<StringParseTree> expression(Characters input)
        => or<StringParseTree, StringParseTree, Character>(
            alternation,
            atomarExpressions
        )(input);

StringParser alternationChar = or(literal('|'), literal('/'));

StringParser<StringParseTree> alternation
        = or(
            right(alternationChar, alternationAtom),
            alternationAtom
        );

StringParser<StringParseTree> alternationAtom
        = nodeParser(
            "Alternation",
            oneOrMore<StringParseTree, Character>(
                nodeParser(
                    "Branch",
                    s_ign(right(
                        alternationChar,
                        oneOrMore<StringParseTree, Character>(
                            s_ign(atomarExpression)
                        )
                    ))
                )
            )
        );

StringParser<StringParseTree> atomarExpressions
        = nodeParser("Expressions", oneOrMore<StringParseTree, Character>(s_ign(atomarExpression)));

"Like [[expression]], but without alternation, infix or postfix operators, or
 any other parsers causing left-recursives trouble."
StringParser<StringParseTree> atomarExpression
        = anyOf(
            pSingleQuoteString,
            pDoubleQuoteString,
            pHiddenElement,
            pGroup,
            pEpsilon,
            name
        );

StringParser<StringToken> name = tokenParser("Name", manySatisfy((Character char) => char.letter || char.digit, "name"));

StringParser<StringToken> pEpsilon
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

StringParser<StringToken> pSingleQuoteString
        => tokenParser("String", backslashEscapable(literal('\''), stringEscapeMap));
StringParser<StringToken> pDoubleQuoteString
        => tokenParser("String", backslashEscapable(literal('"'), stringEscapeMap));

StringParser<StringNodes> pHiddenElement
        = nodeParser("HiddenElement", betweenLiteral('<', expression, '>'));

StringParser<StringNodes> pGroup
        = nodeParser("Group", betweenLiteral('(', expression, ')'));

StringParser<StringToken> pComment
        = tokenParser("Comment", or(
            between(literals("(*"), anyLiteral<Character>, literals("*)")),
            between(literals("/*"), anyLiteral<Character>, literals("*/"))
        ));

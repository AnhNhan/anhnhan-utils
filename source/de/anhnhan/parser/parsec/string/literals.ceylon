/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.language {
    ceylon_not=not
}

import de.anhnhan.parser.parsec {
    literal,
    skipLiteral,
    skip,
    satisfy,
    Parser,
    zeroOrMore,
    ignore,
    literals,
    left,
    ignoreSurrounding
}

shared
StringParser newline
        = literal('\n');
shared
StringParser<Character[]> skipNewline
        = skipLiteral('\n');

shared
StringParser whitespace
        = satisfy(Character.whitespace);
shared
StringParser<[]> skipWhitespace
        = skip(whitespace);
shared
StringParser<[]> ignoreWhitespace
        = ignore(zeroOrMore(whitespace));
shared
StringParser<Literal> trimWhitespace<Literal>(Parser<Literal, Character> parser)
        => ignoreSurrounding<Literal, Character>(zeroOrMore(whitespace))(parser);

shared
StringParser tab
        = literal('\t');

shared
StringParser lowercase
        = satisfy(isLower);

shared
StringParser uppercase
        = satisfy(isUpper);

shared
StringParser asciiLower
        = satisfy(isAsciiLower);

shared
StringParser asciiUpper
        = satisfy(isAsciiUpper);

shared
StringParser letter
        = satisfy(isLetter);

shared
StringParser asciiLetter
        = satisfy(isAsciiLetter);

shared
StringParser digit
        = satisfy(isDigit);

shared
StringParser hex
        = satisfy(isHex);

shared
StringParser<Character[]> keyword({Character*} keyword)
        => left(literals(String(keyword)), satisfy(ceylon_not(isLetterOrDigit)));

shared
StringParser letterOrDigit
        = satisfy(isLetterOrDigit);

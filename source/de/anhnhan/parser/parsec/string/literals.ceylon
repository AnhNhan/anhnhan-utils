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
    or,
    ignore,
    literals,
    left,
    ignoreSurrounding,
    emptyLiteral
}

shared
StringParser<Character> newline
        = literal('\n');
shared
StringParser<Character[]> skipNewline
        = skipLiteral('\n');

shared
StringParser<Character> whitespace
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
StringParser<Character> tab
        = literal('\t');

shared
StringParser<Character> lowercase
        = satisfy(isLower);

shared
StringParser<Character> uppercase
        = satisfy(isUpper);

shared
StringParser<Character> asciiLower
        = satisfy(isAsciiLower);

shared
StringParser<Character> asciiUpper
        = satisfy(isAsciiUpper);

shared
StringParser<Character> letter
        = satisfy(isLetter);

shared
StringParser<Character> asciiLetter
        = satisfy(isAsciiLetter);

shared
StringParser<Character> digit
        = satisfy(isDigit);

shared
StringParser<Character> hex
        = satisfy(isHex);

shared
StringParser<Character[]> keyword({Character*} keyword)
        => left(literals(String(keyword)), satisfy(ceylon_not(isLetterOrDigit)));

"Like `keyword`, but allowed to be at end of stream. Useful for e.g. true, false, null"
shared
StringParser<Character[]> keyword2({Character*} keyword)
        => left(literals(String(keyword)), or(satisfy(ceylon_not(isLetterOrDigit)), emptyLiteral<Character>));

shared
StringParser<Character> letterOrDigit
        = satisfy(isLetterOrDigit);

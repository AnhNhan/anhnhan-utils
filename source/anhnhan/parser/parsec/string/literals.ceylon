/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import anhnhan.parser.parsec {
    literal,
    skipLiteral,
    skip,
    satisfy,
    Parser
}

shared
StringParser newline
        = literal('\n');
shared
Parser<Anything[], Character> skipNewline
        = skipLiteral('\n');

shared
StringParser whitespace
        = satisfy(Character.whitespace);
shared
Parser<Anything[], Character> skipWhitespace
        = skip(whitespace);

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

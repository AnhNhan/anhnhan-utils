/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import anhnhan.parser.parsec {
    ParseResult,
    literal,
    skipLiteral,
    skip,
    satisfy
}

shared
StringParseResult({Character*}) newline
        = literal('\n');
shared
ParseResult<Anything[], {Character*}>({Character*}) skipNewline
        = skipLiteral<Character, {Character*}>('\n');

shared
StringParseResult({Character*}) whitespace
        = satisfy(Character.whitespace);
shared
ParseResult<Anything[], {Character*}>({Character*}) skipWhitespace
        = skip<Character>(whitespace);

shared
StringParseResult({Character*}) tab
        = literal('\t');

shared
StringParseResult({Character*}) lowercase
        = satisfy(isLower);

shared
StringParseResult({Character*}) uppercase
        = satisfy(isUpper);

shared
StringParseResult({Character*}) asciiLower
        = satisfy(isAsciiLower);

shared
StringParseResult({Character*}) asciiUpper
        = satisfy(isAsciiUpper);

shared
StringParseResult({Character*}) letter
        = satisfy(isLetter);

shared
StringParseResult({Character*}) asciiLetter
        = satisfy(isAsciiLetter);

shared
StringParseResult({Character*}) digit
        = satisfy(isDigit);

shared
StringParseResult({Character*}) hex
        = satisfy(isHex);

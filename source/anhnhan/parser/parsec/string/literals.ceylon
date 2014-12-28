/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import anhnhan.parser.parsec {
    ParseResult,
    literal,
    skipLiteral,
    matchAtomIf,
    skip
}

shared
ParseResult<Character, {Character*}>({Character*}) newline => literal('\n');
shared
ParseResult<Anything[], {Character*}>({Character*}) skipNewline => skipLiteral<Character, {Character*}>('\n');

shared
ParseResult<Character, {Character*}>({Character*}) whitespace => matchAtomIf(Character.whitespace);
shared
ParseResult<Anything[], {Character*}>({Character*}) skipWhitespace => skip<Character>(whitespace);

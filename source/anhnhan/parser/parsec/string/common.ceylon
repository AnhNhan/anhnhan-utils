/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import anhnhan.parser.parsec {
    Parser,
    ParseResult
}

shared
alias StringParseResult
        => ParseResult<Character, Character>;

shared
interface StringParser
        => Parser<Character, Character>;

shared
interface CharacterPredicate
        => Boolean(Character);

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
alias StringParseResult<Literal = Character>
        => ParseResult<Literal, Character>;

shared
interface StringParser<Literal = Character>
        => Parser<Literal, Character>;

shared
interface CharacterPredicate
        => Boolean(Character);

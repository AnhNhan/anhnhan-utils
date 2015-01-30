/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import de.anhnhan.parser.parsec {
    Parser,
    ParseResult
}

shared
alias StringParseResult<out Literal = Character>
        => ParseResult<Literal, Character>;

shared
interface StringParser<out Literal = Character>
        => Parser<Literal, Character>;

shared
interface CharacterPredicate
        => Boolean(Character);

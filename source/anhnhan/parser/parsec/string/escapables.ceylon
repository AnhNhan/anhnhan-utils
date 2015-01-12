/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import anhnhan.parser.parsec {
    Parser,
    anyLiteral,
    escapeBetween,
    literal
}

shared
Parser<Character[], Character> backslashEscapable(
    Parser<Anything, Character> delim,
    Character(Character) escapeApply,
    Parser<Anything, Character> delimR = delim,
    Parser<Character, Character> inner = anyLiteral<Character>
)
    => escapeBetween(literal('\\'), delim, inner, escapeApply, delimR);

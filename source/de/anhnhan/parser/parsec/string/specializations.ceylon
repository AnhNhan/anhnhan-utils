/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import de.anhnhan.parser.parsec {
    apply,
    oneOrMore,
    zeroOrMore
}

shared
StringParser<String> zero_or_more_chars(StringParser<Character> parser)
        => apply(zeroOrMore(parser), `String`);

shared
StringParser<String> one_or_more_chars(StringParser<Character> parser)
        => apply(oneOrMore(parser), `String`);

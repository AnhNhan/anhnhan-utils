/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import anhnhan.parser.parsec {
    Ok
}
import anhnhan.parser.tree {
    StringNodes
}

import ceylon.test {
    test
}

test
void grammar_parse_success_test()
{
    value grammars = {
        """
           S: ABs
           ABs: A ABs | B ABs | eps
           A: 'a'
           B: 'b'
           ignore: "S: ABs A: 'a'"
           """,
        """S: ABs ABs: A ABs | B ABs | eps(*somecomment*)ignore: "S: ABs A: 'a'""b"
           """
    };

    for (grammar in grammars)
    {
        value result = parseGrammar(grammar);
        print(result);
        assert(is Ok<StringNodes, Character> result);
    }
}

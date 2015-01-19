/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import anhnhan.parser.parsec.test {
    assertCanParseWithNothingLeft
}
import anhnhan.parser.tree {
    nodes,
    token,
    ParseTree
}

import ceylon.test {
    test,
    assertEquals
}

test
void grammar_parse_success_test()
{
    value grammars = {
        """
           (* This some cool-ass grammar, yo? *)
           S: ABs
           ABs: A ABs /*really-cool*/ | B ABs | eps
           A: 'a'
           B: 'b'
           ignore: "S: ABs A: 'a'"
           """,
        """S: ABs ABs: A ABs | B ABs | eps(*somecomment*)ignore: "S: ABs A: 'a'""b"
           """,
        """S:
            | A B
            | <C> D <E F>
           """
    };

    grammars.collect(assertCanParseWithNothingLeft(parseGrammar));
}

"Did I use the right word?"
test
void grammar_dissected()
{
    function tok<InputElement>(String name, {InputElement*} elements)
            => token<InputElement>(name)(elements.sequence());
    function node<InputElement>(String name, {ParseTree<InputElement>*} elements)
            => nodes<InputElement>(name)(elements.sequence());

    function name(String name)
            => tok("Name", name);

    value grammar
            = """S: A? (B C | D)+ <E?> <F>? | [G H] (I "S: ABs A: 'a'""b" J)
                 """;
    value tree = assertCanParseWithNothingLeft(parseGrammar)(grammar).result;
print(tree.render());
    value expectedTree
            = node("Grammar", [
                node("Rule", [
                    tok("Name", "S"),
                    node("Expressions", [node("Alternation", [
                        node("Branch", [
                            node("Optional", [tok("Name", "A")]),
                            node("OneOrMore", [node("Group", [node("Alternation", [node("Branch", [tok("Name", "B"), tok("Name", "C")]), node("Branch", [tok("Name", "D")])])])]),
                            node("HiddenElement", [node("Optional", [tok("Name", "E")])]),
                            node("Optional", [node("HiddenElement", [tok("Name", "F")])])
                        ]),
                        node("Branch", [
                            node("Optional", [name("G"), name("H")]),
                            node("Group", [node("Alternation", [node("Branch", [
                                name("I"),
                                tok("String", "S: ABs A: 'a'"),
                                tok("String", "b"),
                                name("J")
                            ])])])
                        ])
                    ])])
                ])
            ]);

    assertEquals(tree, expectedTree);
}

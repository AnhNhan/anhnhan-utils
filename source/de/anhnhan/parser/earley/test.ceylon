/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.test {
    test
}

test
void generate_catalan_numbers()
{
    value sym  = Rule("SYM", [Terminal("a")]);
    value op   = Rule("OP", [Terminal("+")]);
    value expr = Rule("EXPR", [sym]);
    expr.add([expr, op, expr]);

    for (nn in 1..9)
    {
        value text = " + ".join(["a"].repeat(nn));
        value q0 = parseString(expr, text);
        value forest = build_trees(q0);
        print("``text``: ``forest.size``");
    }
}

test
void natural_language()
{
    value n = Rule("N"
                  , [Terminal("time")]
                  , [Terminal("flight")]
                  , [Terminal("banana")]
                  , [Terminal("flies")]
                  , [Terminal("boy")]
                  , [Terminal("telescope")]
                );
    value d = Rule("D"
                  , [Terminal("the")]
                  , [Terminal("a")]
                  , [Terminal("an")]
                );
    value v = Rule("V"
                  , [Terminal("book")]
                  , [Terminal("eat")]
                  , [Terminal("sleep")]
                  , [Terminal("saw")]
                );
    value p = Rule("P"
                  , [Terminal("with")]
                  , [Terminal("in")]
                  , [Terminal("on")]
                  , [Terminal("at")]
                  , [Terminal("through")]
                );

    value pp = Rule<String>("PP");
    value np = Rule("NP"
                  , [d, n]
                  , [Terminal("john")]
                  , [Terminal("houston")]
                );
    np.add([np, pp]);
    pp.add([p, np]);

    value vp = Rule("VP"
                  , [v, np]
                );
    vp.add([vp, pp]);
    value s = Rule("S"
                  , [np, vp]
                  , [vp]
                );

    for (tree in build_trees(parseString(s, "book the flight through houston")))
    {
        print("--------------------------");
        print(tree);
    }

    for (tree in build_trees(parseString(s, "john saw the boy with the telescope")))
    {
        print("--------------------------");
        print(tree);
    }

    print("Done.\n");
}

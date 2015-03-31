/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared final
class Tree<Element>(shared Element element, shared Tree<Element>[] children)
{}

shared
Tree<State<Element>>[] build_trees<Element>(State<Element> state)
        => build_trees_helper<Element>([] of Tree<State<Element>>[], state, state.rules.size - 1, state.end_column);

Tree<State<Element>>[] build_trees_helper<Element>(Tree<State<Element>>[] children, State<Element> state, Integer rule_index, Column<Element>? end_column)
{
    if (rule_index < 0)
    {
        return [Tree(state, children)];
    }

    Column<Element>? start_column = rule_index == 0 then state.start_column;

    "Invalid rule index given."
    assert (exists rule = state.rules[rule_index]);
    variable
    value outputs = [] of Tree<State<Element>>[];
    for (st in end_column?.states else [])
    {
        if (st == state)
        {
            break;
        }
        if (!st.completed || st.name != rule.name)
        {
            continue;
        }
        if (exists start_column, start_column != st.start_column)
        {
            continue;
        }

        for (sub_tree in build_trees(st))
        {
            for (node in build_trees_helper([sub_tree].append(children), state, rule_index - 1, st.start_column))
            {
                outputs = outputs.append([node]);
            }
        }
    }
    return outputs;
}

/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import de.anhnhan.utils {
    acceptEntry
}

void predict<Element>(Column<Element> column, Rule<Element> rule)
        => rule.map((prod) => State(rule.name, prod, 0, column)).collect(column.add);

void scan<Element>(Column<Element> column, State<Element> state, Terminal<Element> token)
{
    if (token != column.token)
    {
        return;
    }

    column.add(State(state.name, state.production, state.dot_index + 1, state.start_column));
}

void complete<Element>(Column<Element> column, State<Element> state)
{
    if (!state.completed)
    {
        return;
    }

    for (st in state.start_column.states)
    {
        value term = st.next_term;
        if (is Rule<Element> term)
        {
            if (term.name == state.name)
            {
                column.add(State(st.name, st.production, st.dot_index + 1, st.start_column));
            }
        }
    }
}

shared
State<String> parseString(Rule<String> rule, String text)
{
    value gamma_rule = "gamme-rule asdf \{LATIN SMALL LETTER GAMMA}";

    value tokens = text.split().sequence();
    if (tokens.empty) // For now, throw an exception
    {
        throw Exception("Empty input.");
    }
    assert (nonempty tokens);

    value table = tokens.indexed.map(acceptEntry((Integer ii, String token) => Column(ii, Terminal(token))));
    table.first.add(State(gamma_rule, [rule], 0, table.first));

    for (ii->column in table.indexed)
    {
        variable
        value state_index = 0;
        while (!column.states.empty)
        {
            assert (exists state = column.states[state_index++]);

            if (state.completed)
            {
                complete(column, state);
            }
            else
            {
                value term = state.next_term;
                if (is Rule<String> term)
                {
                    predict(column, term);
                }
                else if (ii + 1 < table.size, is Terminal<String> term)
                {
                    assert (exists next_column = table.getFromFirst(ii + 1));
                    scan(next_column, state, term);
                }
                else
                {
                    "Invalid"
                    assert (false);
                }
            }
        }
    }

    value last_column_states = table.last.states;
    for (st in last_column_states)
    {
        if (st.name == gamma_rule && st.completed)
        {
            return st;
        }
    }

    print("\n\n".join(table*.prettyPrint()));
    throw Exception("Parsing failed!");
}

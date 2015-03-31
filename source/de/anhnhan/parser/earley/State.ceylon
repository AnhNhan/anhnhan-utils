/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared final
class State<Element>(
    shared
    String name,
    shared
    Production<Element> production,
    shared
    Integer dot_index,
    shared
    Column<Element> start_column
)
{
    assert (!name.empty);
    assert (dot_index >= 0);

    variable
    Rule<Element>[] tmp_rules = [];
    for (term in production)
    {
        if (is Rule<Element> term)
        {
            tmp_rules = tmp_rules.append([term]);
        }
    }

    shared
    Rule<Element>[] rules = tmp_rules;

    shared
    Boolean completed = dot_index >= production.size;

    variable
    Column<Element>? _end_column = null;

    shared
    Column<Element>? end_column => _end_column;
    assign end_column
    {
        if (exists _ = _end_column)
        {
            throw Exception("end_column already set.");
        }

        _end_column = end_column;
    }

    shared
    ProductionTerm<Element>? next_term;

    if (!completed)
    {
        if (dot_index < production.size)
        {
            next_term = production[dot_index];
        }
        else
        {
            next_term = null;
        }
    }
    else
    {
        next_term = null;
    }
}

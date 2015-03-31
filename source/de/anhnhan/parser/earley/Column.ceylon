/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.collection {
    LinkedList,
    MutableList
}

shared final
class Column<Element>(
    shared
    Integer index,
    shared
    Terminal<Element> token
)
{
    shared
    MutableList<State<Element>> states = LinkedList<State<Element>>();

    shared
    Boolean add(State<Element> state)
    {
        if (state in states)
        {
            return false;
        }

        state.end_column = this;
        states.add(state);
        return true;
    }
}

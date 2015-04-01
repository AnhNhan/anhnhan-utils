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
            print("Didn't add state ``state``.");
            return false;
        }

        state.end_column = this;
        states.add(state);
        print("Added state ``state``.");
        print ("``states``.\n\n");
        return true;
    }

    shared
    String prettyPrint(Boolean show_uncompleted = true)
    {
        variable
        String result = "\nColumn [``index``] '``token``'
                         =======================================";
        for (st in states)
        {
            if (st.completed || show_uncompleted)
            {
                result += st.string + "\n";
            }
        }
        result += "\n";
        return result;
    }
}

/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import de.anhnhan.utils {
    nullableEquality
}

shared final
class Terminal<Element>(shared Element terminal)
        extends ProductionTerm<Element>()
{
    shared actual
    Boolean equals(Object that)
    {
        if (is Terminal<Element> that)
        {
            return nullableEquality(terminal, that.terminal);
        }
        else {
            return false;
        }
    }

    shared actual
    Integer hash
    {
        variable value hash = 1;
        hash = 31*hash + (terminal?.hash else 0);
        return hash;
    }
}

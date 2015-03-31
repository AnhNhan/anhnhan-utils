/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.collection {
    MutableList,
    LinkedList
}

shared
class Rule<Element>(
    shared
    String name,
    Production<Element>* initial_productions
)
        extends ProductionTerm<Element>()
        satisfies {Production<Element>*}
{
    shared
    MutableList<Production<Element>> productions = LinkedList(initial_productions);

    iterator() => productions.iterator();

    shared
    void add(Production<Element> production)
            => productions.add(production);

    shared actual
    Boolean equals(Object that)
    {
        if (is Rule<Element> that)
        {
            return name==that.name &&
                productions==that.productions;
        }
        else
        {
            return false;
        }
    }

    shared actual
    Integer hash
    {
        variable value hash = 1;
        hash = 31*hash + name.hash;
        hash = 31*hash + productions.hash;
        return hash;
    }
}

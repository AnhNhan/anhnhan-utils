/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared
class SList<Element>(nodes)
        extends Object()
        satisfies STree<SList<Element>, Element>
{
    shared actual
    String name
            = "List";

    shared actual
    {<STree<SList<Element>,Element,Nothing>|Element>*} nodes;
}

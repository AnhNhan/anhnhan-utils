/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import de.anhnhan.utils {
    nullableEquality
}

shared
interface STree<Tree, out Element, out NameExistence=Nothing> of Tree
        satisfies {STree<Tree, Element>|Element*}
        given Tree satisfies STree<Tree, Element>
        given NameExistence satisfies Null
{
    shared formal
    String|NameExistence name;

    shared formal
    {STree<Tree, Element>|Element*} nodes;

    shared default actual
    Iterator<STree<Tree, Element>|Element> iterator()
            => nodes.iterator();

    string => "(``name else ""`` ``{for (node in nodes) node?.string else "<null>"}.interpose(" ").fold("")(plus<String>)``)";

    shared actual
    Boolean equals(Object that)
    {
        // name nulliness does not partake in equality.
        if (is STree<Tree, Element, Null> that)
        {
            return nullableEquality(name, that.name) && nodes == that.nodes;
        }
        else
        {
            return false;
        }
    }

    shared actual
    Integer hash
    {
        variable
        value hash = 1;
        hash = 71*hash + (name?.hash else 0);
        hash = 71*hash + nodes.hash;
        return hash;
    }
}

"Signifies that a data structure supports a representation as an S-Tree."
shared see(`interface STreeDeserializable`)
interface STreeRepresentable<Tree, Element, NameExistence=Nothing>
        given Tree satisfies STree<Tree, Element>
        given NameExistence satisfies Null
{
    "Generates an S-Tree representation of this data structure."
    shared formal
    STree<Tree, Element, NameExistence> toSTree();
}

// TODO: We don't have function interfaces, and also no static methods :/
// How are we supposed to reach this method?
"Signifies that a data structure can be reconstructed from an S-Tree."
shared see(`interface STreeRepresentable`)
interface STreeDeserializable<Obj, Tree, Element, NameExistence=Nothing> of Obj
        given Obj satisfies STreeDeserializable<Obj, Tree, Element, NameExistence>
        given Tree satisfies STree<Tree, Element>
        given NameExistence satisfies Null
{
    "Reconstructs a data structure from an S-Tree."
    shared formal throws(`class Exception`, "when a malformed tree has been given.")
    Obj deserializeSTree(Tree stree);
}

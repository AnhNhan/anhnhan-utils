/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

// This is probably full of shit

import ceylon.collection {
    MutableMap,
    MutableSet,
    HashMap,
    HashSet
}

"Collection to model relational mappings. Currently an explicit interface since
 I'm not sure whether using an alias is going to affect us for implementations.

 Consideration: Have actual index field specified? Infer type from that?

 Consideration: Have category/map building done lazily.
 "
category_collection
shared interface RelationCollection<Element>
    satisfies Category<Element>
    given Element satisfies Object
{
}

shared class RelationMap<IndexBy, Element, Absent = Null>(Map<IndexBy, Element>|Iterable<IndexBy->Element, Absent> elements)
    satisfies RelationCollection<Element> & MutableMap<IndexBy, Element>
    given Element satisfies Object
    given IndexBy satisfies Object
    given Absent satisfies Null
{
    if (!is Absent null)
    {
        //
    }
    else
    {
        // Absent is Nothing
        assert(!elements.empty);
    }
    HashMap<IndexBy, Element> map = HashMap { for (el in elements) el };

    shared actual MutableMap<IndexBy,Element> clone() => RelationMap(map);

    shared actual Boolean defines(Object key) => map.defines(key);

    shared actual Element? get(Object key) => map.get(key);

    shared actual Iterator<IndexBy->Element> iterator() => map.iterator();

    shared actual Boolean equals(Object that) => (this of Map<IndexBy, Element>).equals(that);

    shared actual Integer hash => map.hash;

    shared actual Boolean contains(Object element) => defines(element);

    shared actual Boolean empty => map.empty;

    shared actual String string => map.string;

    shared actual void clear() => map.clear();

    shared actual Element? put(IndexBy key, Element item) => map.put(key, item);

    shared actual Element? remove(IndexBy key) => map.remove(key);


}

shared class RelationSet<Element, Absent = Null>(Set<Element>|Iterable<Element, Absent> elements)
    satisfies RelationCollection<Element> & MutableSet<Element>
    given Element satisfies Object
    given Absent satisfies Null
{
    if (!is Absent null)
    {
        //
    }
    else
    {
        // Absent is Nothing
        assert(!elements.empty);
    }
    MutableSet<Element> set = HashSet { for (el in elements) el };

    shared actual Boolean add(Element element) => set.add(element);

    shared actual void clear() => set.clear();

    shared actual MutableSet<Element> clone() => RelationSet(set);

    shared actual Set<Element> complement<Other>(Set<Other> _set)
        given Other satisfies Object => set.complement(_set);

    shared actual Set<Element|Other> exclusiveUnion<Other>(Set<Other> _set)
        given Other satisfies Object => set.exclusiveUnion(_set);

    shared actual Set<Element&Other> intersection<Other>(Set<Other> _set)
        given Other satisfies Object => set.intersection(_set);

    shared actual Iterator<Element> iterator() => set.iterator();

    shared actual Boolean remove(Element element) => set.remove(element);

    shared actual Set<Element|Other> union<Other>(Set<Other> _set)
        given Other satisfies Object => set.union(_set);

    shared actual Boolean equals(Object that) => (this of Set<Element>).equals(that);

    shared actual Integer hash => set.hash;

}

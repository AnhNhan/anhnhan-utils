/**
    SupplyRunner Source Code

    Not disclosed to public
    share with anhnhan@outlook.com in case of violation
 */

shared interface CollectionOversized of collectionOversized {}
shared object collectionOversized satisfies CollectionOversized {}

"Asserts that the collection has only one element, and retrieves that element.

 Otherwise returns of type [[CollectionOversized]] to signify an oversized
 collection."
shared Element|Absent|CollectionOversized onlyElement<Element, Absent>(Iterable<Element, Absent> collection)
    given Absent satisfies Null
{
    if (collection.size > 1)
    {
        return collectionOversized;
    }

    return collection.first;
}

"Returns the first value that is not null, or null if all values
 are null / no values were provided."
shared T? coalesce<T>(T?* values)
{
    for (val in values)
    {
        if (exists val)
        {
            return val;
        }
    }

    return null;
}

"Stream variant of [[coalesce]], providing every non-null value in `values`.

 Overlaps with [[Iterable.coalesced]]."
shared {T*} coalesced<T>(T?* values)
    => {for (val in values) if (exists val) val};

"Returns the first value that is not empty. It will return the
 last value if all values are empty."
shared T _nonempty<T, U>(T+ values)
    given T satisfies Collection<U>
{
    for (val in values)
    {
        if (!val.empty)
        {
            return val;
        }
    }

    return values.last;
}

"Joins together nested iterables. Like PHP's `array_merge`."
shared {Element*}? joinIterables<Element>({{Element*}*} elements)
    => elements.reduce(({Element*} partial, {Element*} element) => partial.chain(element));

shared Comparison compareByKey<Compared>(Compared->Anything x, Compared->Anything y)
    given Compared satisfies Comparable<Compared>
    => x.key <=> y.key;

shared Comparison invertComparison<Compared>(Comparison(Compared, Compared) comparison)(Compared x, Compared y)
    given Compared satisfies Comparable<Compared>
{
    switch (comparison(x, y))
    case (smaller)
    {
        return larger;
    }
    case (equal)
    {
        return equal;
    }
    case (larger)
    {
        return smaller;
    }
}

shared T sumInterjected<T>(T interjected)(T x, T y)
    given T satisfies Summable<T>
    => x + interjected + y;

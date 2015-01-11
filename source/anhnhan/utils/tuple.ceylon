/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared interface PickFailure of PickFailureImpl
{
    shared formal <Integer->String>? index;
}
shared class PickFailureImpl(shared actual <Integer->String>? index) satisfies PickFailure {}

shared Tuple<TupleElement, TupleFirst, TupleRest>|PickFailure pickTuple<TupleElement, TupleFirst, TupleRest, CorrespondenceValues>([String+] picks)(Correspondence<String, CorrespondenceValues> correspondence)
        given TupleFirst satisfies TupleElement
        given TupleRest satisfies TupleElement[]
{
    variable [TupleElement*] elements = [];

    for (index->pickKey in picks.indexed)
    {
        // Detailed type-check is done later
        if (is TupleElement pick = correspondence[pickKey])
        {
            elements = [pick, *elements];
        }
        else
        {
            return PickFailureImpl(index->pickKey);
        }
    }

    if (elements.empty)
    {
        return PickFailureImpl(null);
    }

    assert(is TupleFirst first = elements.first);

    if (is TupleRest rest = elements.rest)
    {
        return [first, *rest];
    }
    else
    {
        return PickFailureImpl(null);
    }
}

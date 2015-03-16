/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared
[{Element*}, {Element*}] partitionByPredicate<Element>(Boolean predicate(Element element))({Element*} input)
        => [input.filter(predicate), input.filter(not(predicate))];

shared
[{Wanted*}, {Element*}] partitionByType<Wanted, Element = Anything>({Element*} input)
        given Wanted satisfies Element
        => [pickOfType<Wanted>(input), {for (elem in input) if (is Null _ = cast<Wanted>(elem)) elem}];

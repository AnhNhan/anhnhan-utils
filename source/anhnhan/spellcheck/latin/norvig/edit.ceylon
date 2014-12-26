/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import anhnhan.utils {
    chainAll
}

import ceylon.collection {
    HashSet
}

"This can be a big set. For a word of length n, there will be n deletions,
 n-1 transpositions, 26n alterations, and 26(n+1) insertions, for a total
 of 54n+25 (of which a few are typically duplicates)."
shared Set<String> edits1(String word)
{
    value splits = [for (ii in 0..word.size) [String(word.sublistTo(ii)), String(word.sublistFrom(ii))]];
    String[] deletes = [for (split in splits) if (!split[1].empty) split[0] + split[1]];
    String[] transposes = [
        for (split in splits)
            if (split[1].size > 1)
                String(
                    split[0]
                            .sequence()
                            .chain({split[1][1] else nothing})
                            .chain({split[1][0] else nothing})
                            .chain(split[1].sublistFrom(2))
                )];
    String[] replaces = [for (split in splits) if (!split[1].empty) for (char in alphabet)
        String(chainAll(split[0], {char}, split[1].sublistFrom(1)))
    ];
    String[] inserts = [for (split in splits) if (!split[1].empty) for (char in alphabet)
        String(chainAll(split[0], {char}, split[1]))
    ];

    return HashSet { elements = chainAll(deletes, transposes, replaces, inserts); };
}

shared Set<String> edits2(String word)
    => HashSet { elements = {for (e1 in edits1(word)) for (e2 in edits1(e1)) e2}; };

shared Set<String> edits2_in(Category<String> set, String word)
    => HashSet { elements = {for (e1 in edits1(word)) for (e2 in edits1(e1)) if (e2 in set) e2}; };

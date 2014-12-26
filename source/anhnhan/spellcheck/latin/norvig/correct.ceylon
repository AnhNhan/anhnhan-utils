/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.collection {
    HashSet
}

shared Set<String> knowns(Set<String> set, {String*} words)
    => set.intersection(HashSet { elements = words; });

shared Set<String> corrects(Set<String> set, String word)
    => knowns(set, {word}).union(knowns(set, edits1(word))).union(edits2_in(set, word));



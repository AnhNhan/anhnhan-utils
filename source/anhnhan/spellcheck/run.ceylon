/**
    Anh Nhan"s utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import anhnhan.spellcheck.latin.norvig {
    train,
    words,
    corrects,
    knowns,
    edits1,
    edits2_in
}
import anhnhan.utils {
    chainAll,
    joinAll
}

import ceylon.collection {
    HashSet
}
import ceylon.file {
    parsePath,
    File,
    lines
}

shared void run() {
    String dictContents;

    value dictFile = parsePath("C:\\Users\\AnhNhan\\SkyDrive\\Downloads\\dev\\big.txt").resource;
    if (is File dictFile)
    {
        if (nonempty lines = chainAll<String>(lines(dictFile)).sequence())
        {
            dictContents = joinAll<String>(lines);
        }
        else
        {
            throw Exception("Empty dict file");
        }
    }
    else
    {
        throw Exception("Dict file does not exist");
    }

    value wordTrainSet = train(words(dictContents));

    value tests = {"forbiden", "descisions",
    "supposidly", "embelishing", "acess", "accesing",
    "accomodation", "acommodation", "acomodation", "acount"};

    value set = HashSet {elements = wordTrainSet.keys;};

    void prnt(String name, {Anything*} elements)
        => print("  ``name``: ``elements`` (``elements.size``)");

    for (testWord in tests)
    {
        print("``testWord``:");
        prnt("corrects", corrects(set, testWord));
        prnt("known edit1", knowns(set, edits1(testWord)));
        prnt("edit2", edits2_in(set, testWord));
        print("");
    }
}
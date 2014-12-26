/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.collection {
    TreeMap,
    HashMap
}
import ceylon.test {
    assertEquals,
    test
}

String vowels = "aeiou";
String consonants = "bcdfghjklmnpqrstvwxyz";
String alphabet = vowels + consonants;
String charSpace = alphabet.lowercased + alphabet.uppercased + " ";

shared String[] words(String text)
    => String(text.filter((Character char) => char in charSpace))
            .lowercased
            .split()
            .sequence()
        ;

shared Map<Element, Integer> train<Element>({Element*} features)
    given Element satisfies Comparable<Element>
{
    value model = TreeMap<Element, Integer>((first, second) => first.compare(second), features.map((feature) => feature->1));

    for (feature in features)
    {
        value count = model[feature] else 1;
        model.put(feature, count + 1);
    }

    return model;
}

String testText1 = "This is a test text! Just ignore it. Test.";

test
void testWords()
{
    assertEquals([
        "this",
        "is",
        "a",
        "test",
        "text",
        "just",
        "ignore",
        "it",
        "test"
    ], words(testText1));
}

test
void testTrain()
{
    assertEquals(HashMap { entries = {
        "this"->2,
        "is"->2,
        "a"->2,
        "test"->3,
        "text"->2,
        "just"->2,
        "ignore"->2,
        "it"->2
    }; }, train(words(testText1)));
}

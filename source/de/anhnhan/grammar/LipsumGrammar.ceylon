/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.test {
    test
}

shared
ContextFreeGrammar<String> lipsumGrammar = grammar({
    rule
    {
        "start";
        {ref("words"), "."},
        {ref("words"), "."},
        {ref("words"), "."},
        {ref("words"), ": ", ref("word"), ", ", ref("word"), ", ", ref("word"), " ", ref("word"), "."},
        {ref("words"), "; ", ref("lowerwords"), "."},
        {ref("words"), "!"},
        {ref("words"), ", \"", ref("words"), ".\""},
        {ref("words"), " (\"", ref("upperword"), " ", ref("upperword"), " ", ref("upperword"), "\") ", ref("lowerwords"), "."},
        {ref("words"), "?"}
    },
    rule
    {
        "words";
        {ref("upperword"), " ", ref("lowerwords")}
    },
    rule
    {
        "upperword";
        {"Lorem"},
        {"Ipsum"},
        {"Dolor"},
        {"Dolores"},
        {"Dolorum"},
        {"Recusandae"},
        {"Sequi"},
        {"Sit"},
        {"Mollitia"},
        {"At"},
        {"Amet"},
        {"Autem"},
        {"Et"}
    },
    rule<String>
    {
        "lowerwords";
        {ref("word")},
        {ref("word"), " ", ref("word")},
        {ref("word"), " ", ref("word"), " ", ref("word")},
        {ref("word"), " ", ref("word"), " ", ref("word"), " ", ref("word")},
        {ref("word"), " ", ref("word"), " ", ref("word"), " ", ref("word"), " ", ref("word")},
        {ref("word"), " ", ref("word"), " ", ref("word"), " ", ref("word"), " ", ref("word")},
        {ref("word"), " ", ref("word"), " ", ref("word"), " ", ref("word"), " ", ref("word"), " ", ref("word")},
        {ref("word"), " ", ref("word"), " ", ref("word"), " ", ref("word"), " ", ref("word"), " ", ref("word")}
    },
    rule
    {
        "word";
        {"ad"},
        {"adipisicing"},
        {"aliqua"},
        {"aliquip"},
        {"amet"},
        {"anim"},
        {"aute"},
        {"cillum"},
        {"commodo"},
        {"consectetur"},
        {"consequat"},
        {"culpa"},
        {"cupidatat"},
        {"deserunt"},
        {"dignissimos"},
        {"do"},
        {"dolor"},
        {"dolore"},
        {"duis"},
        {"ea"},
        {"eiusmod"},
        {"elit"},
        {"enim"},
        {"error"},
        {"esse"},
        {"est"},
        {"et"},
        {"eu"},
        {"eveniet"},
        {"ex"},
        {"excepteur"},
        {"exercitation"},
        {"fugiat"},
        {"id"},
        {"in"},
        {"incididunt"},
        {"ipsum"},
        {"irure"},
        {"labore"},
        {"laboris"},
        {"laborum"},
        {"lorem"},
        {"magna"},
        {"minim"},
        {"mollit"},
        {"nihil"},
        {"nisi"},
        {"non"},
        {"nostrud"},
        {"nulla"},
        {"occaecat"},
        {"officia"},
        {"pariatur"},
        {"proident"},
        {"qui"},
        {"quis"},
        {"quam"},
        {"reprehenderit"},
        {"sed"},
        {"sint"},
        {"sit"},
        {"sunt"},
        {"tempor"},
        {"ullamco"},
        {"ut"},
        {"velit"},
        {"veniam"},
        {"voluptate"},
        {"voluptatem"}
    }
}, "start");

test
void testLipsum()
{
    lipsumGrammar.generateSeveral(10).collect((strs) => print(String(strs.fold<{Character*}>({})((partial, str) => partial.chain(str)))));
}

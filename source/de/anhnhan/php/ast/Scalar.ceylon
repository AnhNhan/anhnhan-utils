/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.collection {
    HashMap,
    MutableMap
}

Map<Character, Character> stringReplacements = HashMap {
    '\\'->'\\',
    '$'->'$',
    'n'->'\n',
    'r'->'\r',
    't'->'\t',
    'f'->'\f',
    'v'->'\{LINE TABULATION}',
    'e'->'\{ESCAPE}'
};
Map<Character, Character> inverseStringReplacements = HashMap {
    entries = zipEntries(stringReplacements.items, stringReplacements.keys);
};

shared final
class StringLiteral(
    shared
    String stringContents,
    shared actual
    MutableMap<String, Object> attributes
            = HashMap<String, Object>()
)
        satisfies Scalar
{
    "For writing to file. We don't inject anything into the Zend engine."
    shared
    String toPHPStringLiteral()
            => String(stringContents.map((char) => inverseStringReplacements[char] else char));

    shared actual
    String render() => "\"``toPHPStringLiteral()``\"";
}

shared final
class NumberLiteral(
    shared
    Float|Integer number,
    shared actual
    MutableMap<String, Object> attributes
            = HashMap<String, Object>()
)
        satisfies Scalar
{
    render() => number.string;
}

shared
interface BooleanLiteral
        of phpTrue | phpFalse
        satisfies Scalar
{}

shared object phpTrue satisfies BooleanLiteral { render() => "true"; attributes = HashMap<String, Object>(); }

shared object phpFalse satisfies BooleanLiteral { render() => "false"; attributes = HashMap<String, Object>(); }

shared object phpNull satisfies Scalar { render() => "null"; attributes = HashMap<String, Object>(); }

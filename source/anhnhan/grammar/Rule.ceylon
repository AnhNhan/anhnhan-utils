/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared
interface Rule<out Terminal>
{
    shared formal
    String name;

    shared formal
    {Production<Terminal>+} productions;

    string => "{``name`` => ``productions``}";
}

shared
interface Production<out Terminal>
        => {Rule<Terminal>|RuleReference|Terminal+};

shared
interface RuleReference
{
    shared formal
    String name;

    shared default actual
    String string => "[``name``]";
}

shared
class EmbeddedGrammar<out Terminal>(name, grammar)
        satisfies Rule<Terminal>
{
    shared actual
    String name;

    ContextFreeGrammar<Terminal> grammar;

    shared actual
    {Production<Terminal>+} productions;
    value rules = grammar.rules.items.collect((_) => {_});
    if (nonempty rules)
    {
        productions = rules;
    }
    else
    {
        throw Exception("Grammar has no rules, can't embed.");
    }
}

shared
Rule<Terminal> rule<Terminal>(String _name, {Production<Terminal>+} _productions)
{
    object rule
            satisfies Rule<Terminal>
    {
        name = _name;
        productions = _productions;
    }
    return rule;
}

shared
RuleReference ref(String _name)
{
    object ref
            satisfies RuleReference
    {
        name = _name;
    }
    return ref;
}

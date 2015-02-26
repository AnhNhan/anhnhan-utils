/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared
interface NonTerminal<out Terminal>
        of Rule<Terminal> | RuleReference
{}

"Represents a rule in a grammar. A rule yields one or more productions, each
 denoting a sequence of tokens and (sub-)rules (which may be referenced within
 the same grammar).

 For parsing, each single production represents an alternative branch to parse.

 When generating a token stream from a grammar, a single production is selected
 at random and applied."
shared see(`function rule`)
interface Rule<out Terminal>
        satisfies NonTerminal<Terminal>
{
    shared formal
    String name;

    shared formal
    {Production<Terminal>+} productions;

    string => "{``name`` => ``productions``}";
}

shared
interface Production<out Terminal>
        => {NonTerminal<Terminal>|Terminal+};

"Allows to reference a rule within a rule production without having to access
 or embed the rule itself."
shared see(`function ref`)
interface RuleReference
        satisfies NonTerminal<Nothing>
{
    shared formal
    String name;

    shared actual default
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

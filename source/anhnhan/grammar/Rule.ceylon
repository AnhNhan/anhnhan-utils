/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared
interface Rule<Terminal>
{
    shared formal
    String name;

    shared formal
    {Production<Terminal>+} productions;

    string => "{``name`` => ``productions``}";
}

shared
interface Production<Terminal>
        => {Rule<Terminal>|RuleReference|Terminal+};

shared
interface RuleReference
{
    shared formal
    String name;

    string => "[``name``]";
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

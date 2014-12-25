/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

// Should routes contain the actual controller(-type), or just a string/controller-name so applications can retrieve the controller for us?

shared interface Route<out Target>
{
    shared formal String pattern;
    shared formal String? subPattern;

    shared formal Target target;

    shared formal String fullPattern;
}

shared final class StdRoute<out Target>(String _pattern, String? _subPattern, target)
    satisfies Route<Target>
{
    shared actual String pattern = _pattern.trim('/'.equals);
    shared actual String? subPattern = _subPattern?.trim('/'.equals);

    shared actual Target target;

    shared actual String fullPattern => pattern + (subPattern exists then "/" + (subPattern else "") else "");

    shared actual String string => "Route(``pattern + (subPattern else "")`` => target)";
}

/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.collection {
    HashMap,
    MutableMap
}

"Represents Doctrine-style annotations in the DocBlock comment."
shared
class DocAnnotation(
    shared
    Name name,
    shared
    {AnnotationParameterMeta*} parameters,
    shared actual
    MutableMap<String, Object> attributes
            = HashMap<String, Object>()
)
        satisfies Node & Renderable
{
    render() => "@``name````parameters.empty then "" else ("(" + ", ".join(parameters*.render()) + ")")``";
}

shared
interface AnnotationParameterMeta
        of NamedParameter | AnnotationParameter
        satisfies Renderable
{}

shared
class NamedParameter(shared String name, shared AnnotationParameter annotation)
        satisfies AnnotationParameterMeta
{
    render() => "``name``=``annotation.render()``";
}

shared
interface AnnotationParameter
        of AnnotationValue | AnnotationList
        satisfies AnnotationParameterMeta
{}

shared
class AnnotationValue(shared Scalar val)
        satisfies AnnotationParameter
{
    render() => val.render();
}

shared
class AnnotationList(
    shared
    {AnnotationParameterMeta*} values
)
        satisfies AnnotationParameter
{
    render() => "{``", ".join(values*.render())``}";
}

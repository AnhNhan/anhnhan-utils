/**
    SupplyRunner Source Code

    Not disclosed to public
    share with anhnhan@outlook.com in case of violation
 */

import ceylon.language.meta.declaration {
    ClassDeclaration,
    FunctionOrValueDeclaration
}

shared final annotation class Methods(methods)
    satisfies OptionalAnnotation<Methods, ClassDeclaration|FunctionOrValueDeclaration>
{
    shared HttpMethod* methods;
}

shared annotation Methods methods(HttpMethod* methods)
    => Methods(*methods);

shared final annotation class Handler(pattern)
    satisfies OptionalAnnotation<Handler, ClassDeclaration|FunctionOrValueDeclaration>
{
    shared String pattern;
}

shared annotation Handler handler(String pattern)
    => Handler(pattern);

shared final annotation class SubHandler(subPattern)
    satisfies OptionalAnnotation<SubHandler, FunctionOrValueDeclaration>
{
    shared String subPattern;
}

shared annotation SubHandler subhandler(String subPattern)
    => SubHandler(subPattern);

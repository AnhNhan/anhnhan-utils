/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared sealed abstract class FunctionOrValueDeclarationImpl(
        String qualifiedName,
        NestableDeclarationImpl|PackageImpl container,
        PackageImpl? containingPackage = null,
        Annotation[] _annotations = [],
        parameter = false,
        defaulted = false,
        variadic = false
    )
    of ValueDeclarationImpl | FunctionDeclarationImpl
    extends NestableDeclarationImpl(qualifiedName, container, containingPackage, _annotations)
{
    shared Boolean parameter;
    shared Boolean defaulted;
    shared Boolean variadic;
}

shared final class ValueDeclarationImpl(
        String qualifiedName,
        NestableDeclarationImpl|PackageImpl container,
        PackageImpl? containingPackage = null,
        Annotation[] _annotations = [],
        objectClass = null,
        Boolean parameter = false,
        Boolean defaulted = false,
        Boolean variadic = false
    )
    extends FunctionOrValueDeclarationImpl(qualifiedName, container, containingPackage, _annotations, parameter, defaulted, variadic)
{
    shared Boolean variable => !(this of AnnotatedDeclarationImpl).annotations<VariableAnnotation>().empty;

    shared ClassDeclarationImpl? objectClass;
    shared Boolean objectValue = objectClass exists;
}

shared final class FunctionDeclarationImpl(
        String qualifiedName,
        NestableDeclarationImpl|PackageImpl container,
        PackageImpl? containingPackage = null,
        Annotation[] _annotations = [],
        Boolean parameter = false,
        Boolean defaulted = false,
        Boolean variadic = false,
        typeParameterDeclarations = []
    )
    extends FunctionOrValueDeclarationImpl(qualifiedName, container, containingPackage, _annotations, parameter, defaulted, variadic)
    satisfies GenericDeclarationImpl
{
    shared actual TypeParameterImpl[] typeParameterDeclarations;
}

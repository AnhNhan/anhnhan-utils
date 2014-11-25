/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.collection {
    HashMap
}

shared object implNothingType extends OpenTypeImpl() {}

shared sealed abstract class OpenTypeImpl()
    of OpenClassOrInterfaceTypeImpl
        | OpenTypeVariableImpl
        | OpenUnionImpl
        | OpenIntersectionImpl
        | implNothingType
{
}

shared final class OpenIntersectionImpl(satisfiedTypes)
    extends OpenTypeImpl()
{
    shared OpenTypeImpl[] satisfiedTypes;
}

shared final class OpenTypeVariableImpl(declaration)
    extends OpenTypeImpl()
{
    shared TypeParameterImpl declaration;
}

shared final class OpenUnionImpl(caseTypes)
    extends OpenTypeImpl()
{
    shared OpenTypeImpl[] caseTypes;
}

shared sealed abstract class OpenClassOrInterfaceTypeImpl(typeArguments = HashMap())
    of OpenClassTypeImpl | OpenInterfaceTypeImpl
    extends OpenTypeImpl()
{
    shared formal ClassOrInterfaceDeclarationImpl declaration;

    shared formal OpenClassTypeImpl? extendedType;
    shared formal OpenInterfaceTypeImpl[] satisfiedTypes;

    shared Map<TypeParameterImpl, OpenTypeImpl> typeArguments;
}

shared final class OpenClassTypeImpl(declaration, Map<TypeParameterImpl, OpenTypeImpl> typeArguments = HashMap())
    extends OpenClassOrInterfaceTypeImpl()
{
    shared actual ClassDeclarationImpl declaration;

    shared actual OpenClassTypeImpl? extendedType => declaration.extendedType;
    shared actual OpenInterfaceTypeImpl[] satisfiedTypes => declaration.satisfiedTypes;
}

shared final class OpenInterfaceTypeImpl(declaration, Map<TypeParameterImpl, OpenTypeImpl> typeArguments = HashMap())
    extends OpenClassOrInterfaceTypeImpl()
{
    shared actual InterfaceDeclarationImpl declaration;

    shared actual OpenClassTypeImpl? extendedType => declaration.extendedType;
    shared actual OpenInterfaceTypeImpl[] satisfiedTypes => declaration.satisfiedTypes;
}

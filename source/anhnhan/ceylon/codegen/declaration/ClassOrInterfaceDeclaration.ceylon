/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

shared abstract class ClassOrInterfaceDeclarationImpl(
        String qualifiedName,
        NestableDeclarationImpl|PackageImpl container,
        PackageImpl? containingPackage = null,
        Annotation[] _annotations = [],
        members = [],
        extendedType = null,
        satisfiedTypes = [],
        caseTypes = [],
        isAlias = false,
        typeParameterDeclarations = []
    )
    of ClassDeclarationImpl | InterfaceDeclarationImpl
    extends NestableDeclarationImpl(qualifiedName, container, containingPackage, _annotations)
    satisfies GenericDeclarationImpl
{
    shared OpenClassTypeImpl? extendedType;
    shared OpenInterfaceTypeImpl[] satisfiedTypes;
    shared OpenTypeImpl[] caseTypes;
    shared Boolean isAlias;

    shared actual TypeParameterImpl[] typeParameterDeclarations;

    variable NestableDeclarationImpl[] members;

    shared Boolean addMember(NestableDeclarationImpl member)
    {
        if (getDeclaredMemberDeclaration<NestableDeclarationImpl>(member.name) exists)
        {
            return false;
        }

        members = [member, *members];
        return true;
    }

    {NestableDeclarationImpl*} chained_members
    {
        value membersFromSatisfiedTypes =
            satisfiedTypes
                *.declaration
                *.chained_members
                .reduce<{NestableDeclarationImpl*}>(
                    (partial, member) => partial.chain(member)
                )
                else {}
        ;

        return members
            .chain(membersFromSatisfiedTypes)
            .chain(extendedType?.declaration?.chained_members else {})
        ;
    }

    shared Kind[] memberDeclarations<Kind>()
        given Kind satisfies NestableDeclarationImpl
        => [for (member in chained_members) if (is Kind member) member];

    shared Kind[] declaredMemberDeclarations<Kind>()
        given Kind satisfies NestableDeclarationImpl
        => [for (member in members) if (is Kind member) member];

    shared Kind? getMemberDeclaration<Kind>(String name)
        given Kind satisfies NestableDeclarationImpl
        => memberDeclarations<Kind>().find((Kind member) => member.name == name);

    shared Kind? getDeclaredMemberDeclaration<Kind>(String name)
        given Kind satisfies NestableDeclarationImpl
        => declaredMemberDeclarations<Kind>().find((Kind member) => member.name == name);
}
shared final class ClassDeclarationImpl(
        String qualifiedName,
        NestableDeclarationImpl|PackageImpl container,
        PackageImpl? containingPackage = null,
        Annotation[] _annotations = [],
        NestableDeclarationImpl[] _members = [],
        objectValue = null
    )
    extends ClassOrInterfaceDeclarationImpl(qualifiedName, container, containingPackage, _annotations, _members)
{
    shared Boolean abstract => !(this of AnnotatedDeclarationImpl).annotations<AbstractAnnotation>().empty;
    shared Boolean final => !(this of AnnotatedDeclarationImpl).annotations<FinalAnnotation>().empty;

    shared ValueDeclarationImpl? objectValue;
    shared Boolean anonymous = objectValue exists;
}
shared final class InterfaceDeclarationImpl(
        String qualifiedName,
        NestableDeclarationImpl|PackageImpl container,
        PackageImpl? containingPackage = null,
        Annotation[] _annotations = [],
        NestableDeclarationImpl[] _members = []
    )
    extends ClassOrInterfaceDeclarationImpl(qualifiedName, container, containingPackage, _annotations, _members)
{
    //
}

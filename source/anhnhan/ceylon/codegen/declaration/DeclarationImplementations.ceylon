/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.language {
    AnnotationType=Annotation
}
import ceylon.language.meta.declaration {
    Variance,
    covariant
}

shared sealed interface GenericDeclarationImpl
{
    shared formal TypeParameterImpl[] typeParameterDeclarations;

    shared default TypeParameterImpl? getTypeParameterDeclaration(String name)
        => typeParameterDeclarations.find((elem) => elem.name == name);
}

shared sealed abstract class DeclarationImpl(qualifiedName)
    of AnnotatedDeclarationImpl | TypeParameterImpl
{
    shared String name = ':' in qualifiedName
        then (qualifiedName.split(':'.equals).last else "<compiler error?>")
        else qualifiedName
    ;

    shared String qualifiedName;
}

shared final class TypeParameterImpl(
        String qualifiedName,
        container, defaulted,
        defaultTypeArgument = null,
        variance = covariant,
        satisfiedTypes = [],
        caseTypes = []
    )
    extends DeclarationImpl(qualifiedName)
{
    shared NestableDeclarationImpl container;
    shared Boolean defaulted;
    shared OpenTypeImpl? defaultTypeArgument;
    shared Variance variance;
    shared OpenTypeImpl[] satisfiedTypes;
    shared OpenTypeImpl[] caseTypes;
}

shared sealed abstract class AnnotatedDeclarationImpl(String qualifiedName, _annotations = [])
    of NestableDeclarationImpl | ModuleImpl | PackageImpl
    extends DeclarationImpl(qualifiedName)
{
    variable AnnotationType[] _annotations;

    shared Boolean addAnnotation<Annotation>(Annotation annotation)
        given Annotation satisfies AnnotationType
    {
        // Hack to check for OptionalAnnotation
        if (annotation is ConstrainedAnnotation<Annotation, Annotation?, Annotated>)
        {
            if (nonempty existing_annotations = annotations<Annotation>())
            {
                return false;
            }
        }

        _annotations = [annotation, *_annotations];
        return true;
    }

    shared Boolean[] addAllAnnotations(AnnotationType* annotations)
    {
        return annotations.collect((annotation) => addAnnotation(annotation));
    }

    shared AnnotationType[] annotations<out Annotation>()
        given Annotation satisfies AnnotationType
        => [for (annotation in _annotations) if (annotation is Annotation) annotation];
}
shared final class PackageImpl(
        String qualifiedName,
        container,
        _members = [],
        Annotation[] _annotations = []
    )
    extends AnnotatedDeclarationImpl(qualifiedName, _annotations)
{
    shared ModuleImpl container;

    variable NestableDeclarationImpl[] _members;

    shared Boolean shared => !annotations<SharedAnnotation>().empty;

    shared Boolean addMember<Kind>(Kind member)
        given Kind satisfies NestableDeclarationImpl
    {
        if (exists existing_member = getMember<NestableDeclarationImpl>(member.name))
        {
            return false;
        }

        _members = [member, *_members];
        return true;
    }

    shared Boolean[] addAllMembers(NestableDeclarationImpl* members)
        => members.collect((member) => addMember(member));

    shared Kind[] members<Kind>()
        given Kind satisfies NestableDeclarationImpl
        => [for (member in _members) if (is Kind member) member];

    shared Kind[] annotatedMembers<Kind, Annotation>()
        given Kind satisfies NestableDeclarationImpl
        given Annotation satisfies AnnotationType
        => [for (member in members<Kind>()) if (nonempty annotations = member.annotations<Annotation>()) member];

    shared Kind? getMember<Kind>(String name)
        given Kind satisfies NestableDeclarationImpl
        => members<Kind>().find((Kind member) => member.name == name);

    shared ValueDeclarationImpl? getValue(String name)
        => getMember<ValueDeclarationImpl>(name);

    shared ClassOrInterfaceDeclarationImpl? getClassOrInterface(String name)
        => getMember<ClassOrInterfaceDeclarationImpl>(name);

    shared FunctionDeclarationImpl? getFunction(String name)
        => getMember<FunctionDeclarationImpl>(name);

    shared AliasDeclarationImpl? getAlias(String name)
        => getMember<AliasDeclarationImpl>(name);
}
shared final class ModuleImpl(
        String name,
        version,
        members = [],
        dependencies = [],
        Annotation[] _annotations = []
    )
    extends AnnotatedDeclarationImpl(name, _annotations)
{
    shared String version;

    shared variable PackageImpl[] members;
    shared variable ImportImpl[] dependencies;

    shared PackageImpl? findPackage(String name)
        => members.find((PackageImpl member) => member.name == name);
}

shared final class ImportImpl(name, version, container, annotations = [])
{
    shared String name;
    shared String version;
    shared ModuleImpl container;
    shared AnnotationType[] annotations;
}

shared sealed abstract class NestableDeclarationImpl(String qualifiedName, container, PackageImpl? _containingPackage = null, AnnotationType[] _annotations = [])
    of FunctionOrValueDeclarationImpl
        | ClassOrInterfaceDeclarationImpl
        | SetterDeclarationImpl
        | AliasDeclarationImpl
    extends AnnotatedDeclarationImpl(qualifiedName, _annotations)
{
    shared default Boolean actual => !(this of AnnotatedDeclarationImpl).annotations<ActualAnnotation>().empty;
    shared default Boolean default => !(this of AnnotatedDeclarationImpl).annotations<DefaultAnnotation>().empty;
    shared default Boolean formal => !(this of AnnotatedDeclarationImpl).annotations<FormalAnnotation>().empty;
    shared default Boolean shared => !(this of AnnotatedDeclarationImpl).annotations<SharedAnnotation>().empty;

    PackageImpl toBeAssignedPackage;
    if (is PackageImpl it = (this of NestableDeclarationImpl).container)
    {
        if (!is Null _containingPackage)
        {
            "Incorrect containing package provided."
            assert(_containingPackage == it);
        }
        toBeAssignedPackage = it;
    }
    else
    {
        assert(exists _containingPackage, is NestableDeclarationImpl it = (this of NestableDeclarationImpl).container);
        assert(_containingPackage == it);
        toBeAssignedPackage = _containingPackage;
    }

    shared default PackageImpl containingPackage = toBeAssignedPackage;
    shared default ModuleImpl containingModule = (this of NestableDeclarationImpl).containingPackage.container;

    shared default NestableDeclarationImpl|PackageImpl container;

    shared default Boolean toplevel = (this of NestableDeclarationImpl).container is PackageImpl;
}

shared final class SetterDeclarationImpl(String qualifiedName, variable, variable NestableDeclarationImpl|PackageImpl container, PackageImpl? _containingPackage = null, AnnotationType[] _annotations = [])
    extends NestableDeclarationImpl(qualifiedName, container, _containingPackage, _annotations)
{
    shared ValueDeclarationImpl variable;

    actual => variable.actual;
    formal => variable.formal;
    default => variable.default;
    shared => variable.shared;
    containingPackage => variable.containingPackage;
    containingModule => variable.containingModule;
    container = variable.container;
    toplevel => variable.toplevel;
}

shared final class AliasDeclarationImpl(String qualifiedName, extendedType, NestableDeclarationImpl|PackageImpl container, PackageImpl? _containingPackage = null, AnnotationType[] _annotations = [])
    extends NestableDeclarationImpl(qualifiedName, container, _containingPackage, _annotations)
{
    shared OpenTypeImpl extendedType;
}

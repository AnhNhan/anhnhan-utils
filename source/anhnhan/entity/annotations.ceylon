/**
    Anh Nhan's utilities library

    Released under Apache v2.0

    Software provided as-is, no warranty
 */

import ceylon.language.meta.declaration {
    ValueDeclaration,
    ClassOrInterfaceDeclaration,
    FunctionOrValueDeclaration
}

// TODO: Cross-db references? Like the ones we're doing in Converge?

shared interface DataModelingAnnotation
    of RelationshipAnnotation | SqlImplAnnotation | SqlHandlingAnnotation
    satisfies OptionalAnnotation<DataModelingAnnotation, Annotated>
{}
shared interface RelationshipAnnotation
    of OneToManyAnnotation | OneToOneAnnotation | ManyToOneAnnotation | ManyToManyAnnotation
    satisfies DataModelingAnnotation
{}
shared interface SqlImplAnnotation
    of FieldAnnotation | TableAnnotation | DataStructure
    satisfies DataModelingAnnotation
{}
shared interface SqlHandlingAnnotation
    of LazyCollection | CategoryCollection | RelationParameter | RelationIndexField
    satisfies DataModelingAnnotation
{}


shared final annotation class OneToManyAnnotation(shared ClassOrInterfaceDeclaration targetClass, shared Boolean mirror = true)
    satisfies RelationshipAnnotation & OptionalAnnotation<OneToManyAnnotation, ValueDeclaration> {}
shared annotation OneToManyAnnotation oneToMany(ClassOrInterfaceDeclaration classDeclaration, Boolean mirror = true)
    => OneToManyAnnotation(classDeclaration, mirror);


shared final annotation class ManyToOneAnnotation(shared ClassOrInterfaceDeclaration targetClass, shared Boolean mirror = true)
    satisfies RelationshipAnnotation & OptionalAnnotation<ManyToOneAnnotation, ValueDeclaration> {}
shared annotation ManyToOneAnnotation manyToOne(ClassOrInterfaceDeclaration classDeclaration, Boolean mirror = true)
    => ManyToOneAnnotation(classDeclaration, mirror);


shared final annotation class ManyToManyAnnotation(shared ClassOrInterfaceDeclaration targetClass, shared ValueDeclaration invertedBy, shared Boolean mirror = true)
    satisfies RelationshipAnnotation & OptionalAnnotation<ManyToManyAnnotation, ValueDeclaration> {}
shared annotation ManyToManyAnnotation manyToMany(ClassOrInterfaceDeclaration classDeclaration, ValueDeclaration invertedBy, Boolean mirror = true)
    => ManyToManyAnnotation(classDeclaration, invertedBy, mirror);


shared final annotation class OneToOneAnnotation(shared ClassOrInterfaceDeclaration targetClass, shared Boolean mirror = true)
    satisfies RelationshipAnnotation & OptionalAnnotation<OneToOneAnnotation, ValueDeclaration> {}
shared annotation OneToOneAnnotation oneToOne(ClassOrInterfaceDeclaration classDeclaration, Boolean mirror = true)
    => OneToOneAnnotation(classDeclaration, mirror);


shared final annotation class FieldAnnotation
    (
        shared SqlType type,
        shared Boolean unique = false,
        // TODO: Infer nullable from function/value type?
        shared Boolean nullable = false,
        "For VARCHAR and stuff"
        shared Integer length = 0
    )
    satisfies SqlImplAnnotation & OptionalAnnotation<FieldAnnotation, ValueDeclaration> {}
shared annotation FieldAnnotation field(SqlType type, Boolean unique = false, Boolean nullable = false, Integer length = 0)
        => FieldAnnotation(type, unique, nullable, length);


shared final annotation class TableAnnotation
    (
        "The name of the table. Leave empty to have it generated."
        shared String name = "",
        "Whether to generate a column called id that is a SEQUENCE / AUTO INCREMENT column."
        shared Boolean useAutoId = true,
        "Whether to auto-initialize `createdAd` and `modifiedAt` fields with the current date on creation."
        shared Boolean autoInitDates = true
    )
    satisfies SqlImplAnnotation & OptionalAnnotation<TableAnnotation, ClassOrInterfaceDeclaration> {}
shared annotation TableAnnotation table(String name = "", Boolean useAutoId = true, Boolean autoInitDates = true)
    => TableAnnotation(name, useAutoId, autoInitDates);


shared final annotation class DataStructure()
    satisfies SqlImplAnnotation & OptionalAnnotation<DataStructure, ClassOrInterfaceDeclaration> {}
shared annotation DataStructure datastructure()
        => DataStructure();

shared final annotation class LazyCollection()
    satisfies SqlHandlingAnnotation & OptionalAnnotation<LazyCollection, FunctionOrValueDeclaration> {}
shared annotation LazyCollection lazy()
    => LazyCollection();

shared final annotation class CategoryCollection()
    satisfies SqlHandlingAnnotation & OptionalAnnotation<CategoryCollection, FunctionOrValueDeclaration> {}
shared annotation CategoryCollection category_collection()
    => CategoryCollection();


"This is just extra information stored along with each individual relation.

 Using relation parameters forces the use of intermediate relation objects.

 In 1->n relations there would be n parameters. In 1->1 relations, there would
 be a single parameter. Every relation to the same entity but with different
 parameter is seen as separate and thus unique.

 NOTE: Currently we only support the string type."shared final annotation class RelationParameter(shared String name)
    satisfies SqlHandlingAnnotation & SequencedAnnotation<RelationParameter, FunctionOrValueDeclaration> {}
shared annotation RelationParameter relation_parameter(String name)
    => RelationParameter(name);

shared final annotation class RelationIndexField(shared FunctionOrValueDeclaration index_by)
    satisfies SqlHandlingAnnotation & OptionalAnnotation<RelationIndexField, FunctionOrValueDeclaration> {}
shared annotation RelationIndexField index_by(FunctionOrValueDeclaration index_by)
    => RelationIndexField(index_by);
